#!/bin/bash
mkdir -p Downloads
tmp="$1"
echo -n "Enter Title: " 
read title
echo -n "Enter Episode: " 
read episode
chmonimeperc=$(echo "$title" | sed 's/ /%20/g')
#botlist=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq)
animelist=$(curl -s "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode" | jq)
choose=$(echo "$animelist" | jq -r ".content[] .name" | sort | uniq | fzf -m --reverse | sed 's/\[/./g;s/\]/./g')
echo "$choose" > "$tmp"
botnumber=$(echo "$animelist" | grep -B2 "$choose" | head -n1 | grep -o -E '[0-9]+')
botname=$(curl -s "https://api.nibl.co.uk/nibl/bots" | jq -r '.content[] | "\(.id) \(.name)"' | grep "^$botnumber" | awk '{print $2}' | head -n1)
while IFS= read -r line ; do
	pacname=$(echo "$animelist" | grep -B1 "$line" | head -n1 | grep -o -E '[0-9]+')
	xdccget -d Downloads -q "irc.rizon.net" "#nibl" "$botname xdcc send #$pacname"
done < "$tmp"
