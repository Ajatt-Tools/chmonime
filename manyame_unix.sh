#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE}")" >/dev/null 2>&1 && pwd)"
tempsh=$(mktemp)
config="config.conf"
if test -f "$config"; then
    echo -n ""
else
    echo "manyame config setup"
    echo "Enter your preferable folder for download anime."
    echo "e.g. C:\Users\asakura\Downloads\ or /home/asakura/Anime/"
    echo "Don't forget slash at the end!"
    echo -n ''
    read -r animefolder
    if echo "$animefolder" | grep -v '\\$\|/$'; then
        echo "Please, don't forget slash at the end!"
        echo ""
        echo "Press enter to exit"
        read -r key
        exit
    fi
    echo "f $animefolder" >>$config
    echo "Enter preferable quality: 480p, 720p, 1080p or other"
    echo -n ''
    read -r quality
    echo "q $quality" >> $config
    echo "Enter preferable api source: kitsu or mal"
    echo -n ''
    read -r api
    echo "api $api" >> $config
fi

# Config variables
folder=$(grep "^f " $config | awk '{$1=""; print $0}')
api=$(grep "^api" $config | awk '{print $2}')
quality=$(grep "^q " $config | awk '{print $2}')
autoplay=$(grep "^w " $config | awk '{print $2}')
player=$(grep "^p " $config | awk '{print $2}')

echo -n "Enter Title: "
read -r title
echo -n "Enter Episode (leave empty for batch): "
read -r episode

chmonimeperc="${title// /%20}"
botlist=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq -r '.content[] | "\(.id) \(.name)"')
animelist=$(curl -s "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode" | jq '.')
if test "$episode"; then
    choose=$(echo "$animelist"  | jq -r '.content[] | .size + " | " + .name' | sort | uniq | awk '{printf "%s %08.2f\t%s\n", index("KMG", substr($1, length($1))), substr($1, 0, length($1)-1), $0}' | sort | cut -f2,3)
    if test "$quality"; then
        choose1=$(echo "$choose" | grep "$quality")
        choose2=$(echo "$choose" | grep -v "$quality")
        choose=$(echo -e "$choose1" "\n" "$choose2" | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | fzy)
    else
        choose=$(echo "$choose" | fzy)
    fi
else
    choose=$(echo "$animelist" | jq -r '.content[] | .size + " | " + .name' | sort | uniq)
    if test "$quality"; then
        choose1=$(echo "$choose" | grep "$quality")
        choose2=$(echo "$choose" | grep -v "$quality")
        choose=$(echo -e "$choose1" "\n" "$choose2" | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | fzy)
    else
        choose=$(echo "$choose" | fzy)
    fi
fi
choose=$(echo "$choose" | sed 's/^.*| //')
nosquare=$(echo "$choose" | sed 's/_/ /g;s/\(.*\)- .*/\1/;s/[0-9]//g;s/\[[^]]*\]//g;s/[0-9]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | sort -nf | uniq -ci | sort -nr | head -n1 | awk '{ print substr($0, index($0,$2)) }' | sed 's/ /%20/g')
#nosquare=$(echo "$choose" | sed -e 's/_/ /g;s/([^()]*)//g;s/[0-9]//g;s/\[[^]]*\]//g;s/\.[^.]*$//' | grep -oh "\w*" | tr ' ' '\n' | sort -nf | uniq -ci | sort -nr | awk '{array[$2]=$1; sum+=$1} END { for (i in array) printf "%-20s %-15d %6.2f\n", i, array[i], array[i]/sum*100}' | awk '$3>20 {print $1}' | tr '\n' ' ' | sed 's/ $//;s/ /%20/g')
if [[ "$api" == "kitsu" ]] ; then
    dirname=$(curl -s "https://kitsu.io/api/edge/anime?filter\[text\]=$nosquare&page\[limit\]=1&page\[offset\]=0" | jq -r .data[].attributes.canonicalTitle | sed 's/\// /g;s/</ /g;s/>/ /g;s/:/ -/g;s/"/ /g;s/\\/ /g;s/|/ /g;s/?/ /g;s/*/ /g;s/  */ /g')
else
    dirname=$(curl -s "https://api.jikan.moe/v3/search/anime?q=$nosquare&page=1&limit=1" | jq -r .results[].title | sed 's/\// /g;s/</ /g;s/>/ /g;s/:/ - /g;s/"/ /g;s/\\/ /g;s/|/ /g;s/?/ /g;s/*/ /g;s/  */ /g')
fi
foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//;s/\/$//')
echo "mkdir -p \"$foldir\"" >>"$tempsh"
echo "$choose" | while IFS= read -r line; do
    anime=$(echo "$line" | sed 's/\[/\\\[/g;s/\]/\\\]/g;s/ *$//;s/^ *//')
    botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E ' [0-9]+'  | sed 's/^ //')
    botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
    pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E ' [0-9]+' | sed 's/^ //')
    echo "xdccget --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >>"$tempsh"
done
sh "$tempsh"
#fi
