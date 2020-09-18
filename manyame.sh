#!/bin/bash
config="manyame.conf"
if test -f "$config"; then
	echo -n ""
else
	echo "Simple Manyame setup"
	echo "Enter your preferable folder for download anime."
	echo 'e.g. C:\Users\asakura\Downloads\ or /home/asakura/Anime/'
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
	echo "f $animefolder" >> manyame.conf
fi
folder=$(cat manyame.conf | grep ^f | awk '{$1=""; print $0}')
echo -n "Enter Title: "
read -r title
echo -n "Enter Episode: "
read -r episode
chmonimeperc=$(echo "$title" | sed 's/ /%20/g')
#botlist=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq)
animelist=$(curl -s "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode" | jq '.')
choose=$(echo "$animelist" | jq -r '.content[] | .size + " | " + .name' | sort | uniq | fzf -m --reverse)
choose=$(echo "$choose" | sed 's/^.*| //')
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    echo "$choose" > "$1"
else
    true
fi
botnumber=$(echo "$animelist" | grep -B2 "$choose" | head -n1 | grep -o -E '[0-9]+')
botname=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq -r '.content[] | "\(.id) \(.name)"' | grep "^$botnumber" | awk '{print $2}' | head -n1)
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    while IFS= read -r line ; do
	anime=$(echo "$line" |  sed 's/\[/\\\[/g;s/\]/\\\]/g')
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
	dirname=$(echo "$line" | grep "\[.*\]" | grep "\-" | sed -e 's/\[[^][]*\]//g;s/^ //' | awk -F"-" '{print $NR}')
	foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//')
	echo "if not exist \"$foldir\" mkdir \"$foldir\"" >> "$2"
        echo "xdccget.exe --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$2"
    done < "$1"
else
    echo "$choose" | while IFS= read -r line ; do
    	anime=$(echo "$line" | sed 's/\[/\\\[/g;s/\]/\\\]/g')
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+')
	dirname=$(echo "$line" | grep "\[.*\]" | grep "\-" | sed -e 's/\[[^][]*\]//g;s/^ //' | awk -F"-" '{print $NR}')
	foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//')
	mkdir -p "$foldir"
        xdccget -d "$foldir" -q "irc.rizon.net" "#nibl" "$botname xdcc send #$pacname"
    done
fi

