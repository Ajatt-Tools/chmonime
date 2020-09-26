#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE}" )" >/dev/null 2>&1 && pwd )"
if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
    PATH="$PATH;$DIR/Executables"
else
    tempsh=$(mktemp)
fi
config="config.conf"
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
#    echo "Enter preferable quality: 480p, 720p, 1080p or other"
#    echo -n ''
#    read -r quality
#    echo "q $quality" >> $config
#    echo "Enter preferable api source: kitsu or mal"
#    echo -n ''
#    read -r api
#    echo "api $api" >> $config
fi

# Config variables
folder=$(grep "^f " $config | awk '{$1=""; print $0}')
#api=$(grep "^api" $config | awk '{print $2}')
quality=$(grep "^q " $config | awk '{print $2}')

echo -n "Enter Title: "
read -r title
echo -n "Enter Episode (leave empty for batch): "
read -r episode

### Jsonparse - https://github.com/dominictarr/JSON.sh
jsonparse () {
    throw() {
        echo "$*" >&2
        exit 1
    }

    BRIEF=0
    LEAFONLY=0
    PRUNE=0
    NO_HEAD=0
    NORMALIZE_SOLIDUS=0

    usage() {
        echo
        echo "Usage: JSON.sh [-b] [-l] [-p] [-s] [-h]"
        echo
        echo "-p - Prune empty. Exclude fields with empty values."
        echo "-l - Leaf only. Only show leaf nodes, which stops data duplication."
        echo "-b - Brief. Combines 'Leaf only' and 'Prune empty' options."
        echo "-n - No-head. Do not show nodes that have no path (lines that start with [])."
        echo "-s - Remove escng of the solidus symbol (straight slash)."
        echo "-h - This help text."
        echo
    }

    parse_options() {
        set -- "$@"
        local ARGN=$#
        while [ "$ARGN" -ne 0 ]
        do
            case $1 in
                -h) usage
                    exit 0
                    ;;
                -b) BRIEF=1
                    LEAFONLY=1
                    PRUNE=1
                    ;;
                -l) LEAFONLY=1
                    ;;
                -p) PRUNE=1
                    ;;
                -n) NO_HEAD=1
                    ;;
                -s) NORMALIZE_SOLIDUS=1
                    ;;
                ?*) echo "ERROR: Unknown option."
                    usage
                    exit 0
                    ;;
            esac
            shift 1
            ARGN=$((ARGN-1))
        done
    }

    awk_egrep () {
        local pattern_string=$1

        gawk '{
        while ($0) {
            start=match($0, pattern);
            token=substr($0, start, RLENGTH);
            print token;
            $0=substr($0, start+RLENGTH);
        }
    }' pattern="$pattern_string"
    }

    tokenize () {
        local GREP
        local ESCAPE
        local CHAR

        if echo "test string" | egrep -ao --color=never "test" >/dev/null 2>&1
        then
            GREP='egrep -ao --color=never'
        else
            GREP='egrep -ao'
        fi

        if echo "test string" | egrep -o "test" >/dev/null 2>&1
        then
            ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
            CHAR='[^[:cntrl:]"\\]'
        else
            GREP=awk_egrep
            ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
            CHAR='[^[:cntrl:]"\\\\]'
        fi

        local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
        local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
        local KEYWORD='null|false|true'
        local SPACE='[[:space:]]+'

    # Force zsh to expand $A into multiple words
    local is_wordsplit_disabled=$(unsetopt 2>/dev/null | grep -c '^shwordsplit$')
    if [ $is_wordsplit_disabled != 0 ]; then setopt shwordsplit; fi
    $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
    if [ $is_wordsplit_disabled != 0 ]; then unsetopt shwordsplit; fi
    }

    parse_array () {
        local index=0
        local ary=''
        read -r token
        case "$token" in
            ']') ;;
            *)
                while :
                do
                    parse_value "$1" "$index"
                    index=$((index+1))
                    ary="$ary""$value"
                    read -r token
                    case "$token" in
                        ']') break ;;
                        ',') ary="$ary," ;;
                        *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
                    esac
                    read -r token
                done
                ;;
        esac
        [ "$BRIEF" -eq 0 ] && value=$(printf '[%s]' "$ary") || value=
        :
    }

    parse_object () {
        local key
        local obj=''
        read -r token
        case "$token" in
            '}') ;;
            *)
                while :
                do
                    case "$token" in
                        '"'*'"') key=$token ;;
                        *) throw "EXPECTED string GOT ${token:-EOF}" ;;
                    esac
                    read -r token
                    case "$token" in
                        ':') ;;
                        *) throw "EXPECTED : GOT ${token:-EOF}" ;;
                    esac
                    read -r token
                    parse_value "$1" "$key"
                    obj="$obj$key:$value"
                    read -r token
                    case "$token" in
                        '}') break ;;
                        ',') obj="$obj," ;;
                        *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
                    esac
                    read -r token
                done
                ;;
        esac
        [ "$BRIEF" -eq 0 ] && value=$(printf '{%s}' "$obj") || value=
        :
    }

    parse_value () {
        local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
        case "$token" in
            '{') parse_object "$jpath" ;;
            '[') parse_array  "$jpath" ;;
            # At this point, the only valid single-character tokens are digits.
            ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
            *) value=$token
                # if asked, replace solidus ("\/") in json strings with normalized value: "/"
                [ "$NORMALIZE_SOLIDUS" -eq 1 ] && value=$(echo "$value" | sed 's#\\/#/#g')
                isleaf=1
                [ "$value" = '""' ] && isempty=1
                ;;
        esac
        [ "$value" = '' ] && return
        [ "$NO_HEAD" -eq 1 ] && [ -z "$jpath" ] && return

        [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
        [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
        [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
        [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
            [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
                [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
                :
            }

        parse () {
            read -r token
            parse_value
            read -r token
            case "$token" in
                '') ;;
                *) throw "EXPECTED EOF GOT $token" ;;
            esac
        }

    if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]);
    then
        parse_options "$@"
        tokenize | parse
    fi

    # vi: expandtab sw=2 ts=2
}


chmonimeperc=$(echo "$title" | sed 's/ /%20/g')
botlist=$(wget -q -O - "https://api.nibl.co.uk/nibl/bots" | jsonparse -b | awk '/id"]/ { cached = $2 } /name"]/ {print cached " " $2}' | sed 's/"//g')
animelist=$(wget -q -O - "https://api.nibl.co.uk/nibl/search?query=$chmonimeperc&episodeNumber=$episode"  | jsonparse -b)
# For fzy
#if uname | grep -i -q "Windows\|Mingw\|Cygwin" ; then
#   screensize=$(mode | head -n5 | tail -n1 | grep -Eo '[0-9]+$'| awk '{ sum = $1 - 1; print sum}')
#else
#   screensize=$(tput cols)
#fi
if test "$episode"; then
    choose=$(echo "$animelist" |  grep -o "name\"\].*\|size\"\].*" | awk '{getline x;print x;}1' | awk 'NR%2 {printf "%s ",$0;next;}1' | sed 's/size"]//g;s/name"]//g;s/"//g;s/\t//g;s/ / | /' awk '{printf "%s %08.2f\t%s\n", index("KMG", substr($1, length($1))), substr($1, 0, length($1)-1), $0}' | sort | cut -f2,3)
    if test "$quality" ; then
        choose1=$(echo "$choose" | grep "$quality")
        choose2=$(echo "$choose" | grep -v "$quality")
        choose=$(echo -e "$choose1" "\n" "$choose2" | sed -e 's/^[ \t]*//' | fzf -m --reverse --no-sort --exact)
    else
        choose=$(echo "$choose" | fzf -m --reverse --no-sort --exact)
    fi
else
    choose=$(echo "$animelist" |  grep -o "name\"\].*\|size\"\].*" | awk '{getline x;print x;}1' | awk 'NR%2 {printf "%s ",$0;next;}1' | sed 's/size"]//g;s/name"]//g;s/"//g;s/\t//g;s/ / | /' | sort -t'|' -k2)
    if test "$quality" ; then
        choose1=$(echo "$choose" | grep "$quality")
        choose2=$(echo "$choose" | grep -v "$quality")
        choose=$(echo -e "$choose1" "\n" "$choose2" | sed -e 's/^[ \t]*//' | fzf -m --reverse --no-sort --exact)
    else
        choose=$(echo "$choose" | fzf -m --reverse --no-sort --exact)
    fi
fi
choose=$(echo "$choose" | sed 's/^.*| //')
nosquare=$(echo "$choose"  | sed 's/_/ /g;s/\(.*\)- .*/\1/;s/[0-9]//g;s/\[[^]]*\]//g;s/[0-9]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | sort -nf | uniq -ci | sort -nr | head -n1 |awk '{ print substr($0, index($0,$2)) }' | sed 's/ /%20/g')
#nosquare=$(echo "$choose" | sed -e 's/_/ /g;s/([^()]*)//g;s/[0-9]//g;s/\[[^]]*\]//g;s/\.[^.]*$//' | grep -oh "\w*" | tr ' ' '\n' | sort -nf | uniq -ci | sort -nr | awk '{array[$2]=$1; sum+=$1} END { for (i in array) printf "%-20s %-15d %6.2f\n", i, array[i], array[i]/sum*100}' | awk '$3>20 {print $1}' | tr '\n' ' ' | sed 's/ $//;s/ /%20/g')
dirname=$(wget -q -O - "https://kitsu.io/api/edge/anime?filter[text]=$nosquare&page[limit]=1&page[offset]=0" | jsonparse -b |  grep 'canonicalTitle"].*' | sed 's/^.*canonicalTitle"\]//g;s/\t//;s/"//g' | sed 's/\// /g;s/</ /g;s/>/ /g;s/:/ -/g;s/"/ /g;s/\\/ /g;s/|/ /g;s/?/ /g;s/*/ /g;s/  */ /g')
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
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+$')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+$')
        echo "xdccget.exe --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$2"
        echo "timeout 1 >nul" >> "$2"
    done < "$1"
else
    foldir=$(echo "$folder$dirname" | sed 's/^ //;s/ $//;s/\/$//')
    echo "mkdir -p \"$foldir\"" >> "$tempsh"
    echo "$choose" | while IFS= read -r line ; do
        anime=$(echo "$line" | sed 's/\[/\\\[/g;s/\]/\\\]/g')
        botnumber=$(echo "$animelist" | grep -B2 "$anime" | head -n1 | grep -o -E '[0-9]+$')
        botname=$(echo "$botlist" | grep "^$botnumber" | awk '{print $2}' | head -n1)
        pacname=$(echo "$animelist" | grep -B1 "$anime" | head -n1 | grep -o -E '[0-9]+$')
        echo "xdccget --dont-confirm-offsets -d \"$foldir\" -q \"irc.rizon.net\" \"#nibl\" \"$botname xdcc send #$pacname\"" >> "$tempsh"
        echo "sleep 1" >> "$2"
    done
    sh "$tempsh"
fi

