#!/bin/bash
RED='\033[0;31m'
GRE='\033[0;32m'       
YE='\033[0;33m'       
GRAY='\033[1;30m'       
NC='\033[0m'
config="manyame.conf"
if test -f "$config"; then
    echo -n ""
else
    printf "${RED}Manyame config setup${NC}\n"
    printf "${YE}Enter your preferable folder for download anime.${NC}\n"
    printf "${YE}e.g. C:\\\Users\\\asakura\\\Downloads\\\ or /home/asakura/Anime/${NC}\n"
    printf "${YE}Don't forget slash at the end!${NC}\n"
    echo -n ''
    read -r animefolder
    if echo "$animefolder" | grep -v '\\$\|/$' ; then
        echo "${YE}Please, don't forget slash at the end!${NC}\n"
        echo ""
        echo "${YE}Press enter to exit${NC}\n"
        read key
        exit
    fi
    echo "f $animefolder" >> manyame.conf
fi
folder=$(cat manyame.conf | grep ^f | awk '{$1=""; print $0}')
printf "${GRE}Enter Title: ${NC}"
read -r title
printf "${GRE}Enter Episode: $(NC}"
read -r episode
chmonimeperc=$(echo "$title" | sed 's/ /%20/g')
botlist=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq -r '.content[] | "\(.id) \(.name)"')
animelist=$(curl -s "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode" | jq '.')
choose=$(echo "$animelist" | jq -r '.content[] | .size + " | " + .name' | sort | uniq | fzf -m --reverse)
choose=$(echo "$choose" | sed 's/^.*| //')
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    echo "$choose" > "$1"
else
    true
fi
dirname=$(curl -s "https://kitsu.io/api/edge/anime?filter\[text\]=$chmonimeperc&page\[limit\]=1" | ./jq -r .data[].attributes.canonicalTitle)
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    while IFS= read -r line ; do
        anime=$(echo "$line" |  sed 's/\[/\\\[/g;s/\]/\\\]/g')
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
        foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//')
        echo "if not exist \"$foldir\" mkdir \"$foldir\" > nul 2> nul" >> "$2"
        echo "xdccget.exe --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$2"
    done < "$1"
else
    echo "$choose" | while IFS= read -r line ; do
        anime=$(echo "$line" | sed 's/\[/\\\[/g;s/\]/\\\]/g')
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
        foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//')
        mkdir -p "$foldir"
        xdccget -d "$foldir" -q "irc.rizon.net" "#nibl" "$botname xdcc send #$pacname"
    done
fi

