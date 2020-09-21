#!/usr/bin/env sh
DIR="$( cd "$( dirname "${BASH_SOURCE}" )" >/dev/null 2>&1 && pwd )"
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    PATH="$PATH;$DIR"
else
    tempsh=$(mktemp)
fi
config="manyame.conf"
if test -f "$config"; then
    echo -n ""
else
    echo "Manyame config setup"
    echo "Enter your preferable folder for download anime."
    echo "e.g. C:\Users\asakura\Downloads\ or /home/asakura/Anime/"
    echo "Don't forget slash at the end!"
    echo -n ''
    read -r animefolder
    if echo "$animefolder" | grep -v '\\$\|/$' ; then
        echo "Please, don't forget slash at the end!"
        echo ""
        echo "Press enter to exit"
        read key
        exit
    fi
    echo "f $animefolder" >> $config
    echo "Enter preferable api source: kitsu or mal"
    echo -n ''
    read -r api
    echo "api $api" >> $config
fi
folder=$(grep "^f" $config | awk '{$1=""; print $0}')
api=$(grep "^api" $config | awk '{print $2}')
echo -n "Enter Title: "
read -r title
echo -n "Enter Episode: "
read -r episode
chmonimeperc=$(echo "$title" | sed 's/ /%20/g')
botlist=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq -r '.content[] | "\(.id) \(.name)"')
animelist=$(curl -s "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode" | jq '.')
if test "$episode"; then
    choose=$(echo "$animelist" | jq -r '.content[] | .size + " | " + .name' | sort | uniq | awk '{printf "%s %08.2f\t%s\n", index("KMG", substr($1, length($1))), substr($1, 0, length($1)-1), $0}' | sort | cut -f2,3 | fzf -m --reverse --no-sort --exact)
else
    choose=$(echo "$animelist" | jq -r '.content[] | .size + " | " + .name' | sort | uniq  | fzf -m --reverse --no-sort --exact)
fi
choose=$(echo "$choose" | sed 's/^.*| //')
nosquare=$(echo "$choose"  | sed 's/_/ /g;s/\(.*\)- .*/\1/;s/[0-9]//g;s/\[[^]]*\]//g;s/[0-9]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | sort -nf | uniq -ci | sort -nr | head -n1 |awk '{ print substr($0, index($0,$2)) }' | sed 's/ /%20/g')
#nosquare=$(echo "$choose" | sed -e 's/_/ /g;s/([^()]*)//g;s/[0-9]//g;s/\[[^]]*\]//g;s/\.[^.]*$//' | grep -oh "\w*" | tr ' ' '\n' | sort -nf | uniq -ci | sort -nr | awk '{array[$2]=$1; sum+=$1} END { for (i in array) printf "%-20s %-15d %6.2f\n", i, array[i], array[i]/sum*100}' | awk '$3>20 {print $1}' | tr '\n' ' ' | sed 's/ $//;s/ /%20/g')
if [[ "$api" == "kitsu" ]] ; then
    dirname=$(curl -s "https://kitsu.io/api/edge/anime?filter\[text\]=$nosquare&page\[limit\]=1&page\[offset\]=0" | jq -r .data[].attributes.canonicalTitle | sed 's/\// /g;s/</ /g;s/>/ /g;s/:/ -/g;s/"/ /g;s/\\/ /g;s/|/ /g;s/?/ /g;s/*/ /g;s/  */ /g')
else
    dirname=$(curl -s "https://api.jikan.moe/v3/search/anime?q=$nosquare&page=1&limit=1" | jq -r .results[].title | sed 's/\// /g;s/</ /g;s/>/ /g;s/:/ - /g;s/"/ /g;s/\\/ /g;s/|/ /g;s/?/ /g;s/*/ /g;s/  */ /g')
fi
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    echo "$choose" > "$1"
else
    true
fi
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//;s/\/$//;s/\\$//')
    echo "if not exist \"$foldir\" mkdir \"$foldir\" > nul 2> nul" >> "$2"
    while IFS= read -r line ; do
        anime=$(echo "$line" |  sed 's/\[/\\\[/g;s/\]/\\\]/g')
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
        echo "xdccget.exe --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$2"
    done < "$1"
else
    foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//;s/\/$//')
    echo "mkdir -p \"$foldir\"" >> "$tempsh"
    echo "$choose" | while IFS= read -r line ; do
        anime=$(echo "$line" | sed 's/\[/\\\[/g;s/\]/\\\]/g')
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
        echo "xdccget --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$tempsh"
    done
    sh "$tempsh"
fi
