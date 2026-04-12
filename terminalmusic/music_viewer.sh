#!/bin/bash


COLOR_TEXT="\e[38;2;205;214;244m"
COLOR_SUBTEXT="\e[38;2;166;173;200m"
COLOR_ACCENT="\e[38;2;180;190;254m"
RESET="\e[0m"


clear
tput civis

cleanup() {
    kitten icat --clear
    clear
    tput cnorm
    exit
}
trap cleanup SIGINT SIGTERM

LAST_TITLE=""

while true; do
    STATUS=$(playerctl status 2>/dev/null)

    if [ "$STATUS" != "Playing" ] && [ "$STATUS" != "Paused" ]; then
        tput cup 0 0
        tput el
        echo "Aguardando música do navegador..."
        sleep 2
        continue
    fi

    TITLE=$(playerctl metadata title)
    ARTIST=$(playerctl metadata artist)
    ALBUM_ART_URL=$(playerctl metadata mpris:artUrl)
    TEMP_IMG="/tmp/cover.png"


    TERM_COLS=$(tput cols)
    TERM_LINES=$(tput lines)


    if [ "$TITLE" != "$LAST_TITLE" ]; then
        if [[ "$ALBUM_ART_URL" == http* ]]; then
            curl -s -o "$TEMP_IMG" "$ALBUM_ART_URL"
        elif [[ "$ALBUM_ART_URL" == file* ]]; then
            cp "${ALBUM_ART_URL#file://}" "$TEMP_IMG"
        fi

        clear

        kitten icat --clear --align center --scale-up --place "${TERM_COLS}x$((TERM_LINES / 2))@0x1" "$TEMP_IMG"
        LAST_TITLE="$TITLE"
    fi

    OFFSET=$((TERM_LINES / 2 + 2))


    tput cup $OFFSET $(( (TERM_COLS / 2) - (${#TITLE} / 2) ))
    echo -e "${COLOR_TEXT}${TITLE}${RESET}"


    tput cup $((OFFSET + 1)) $(( (TERM_COLS / 2) - (${#ARTIST} / 2) ))
    echo -e "${COLOR_SUBTEXT}${ARTIST}${RESET}"


    CONTROLS="|<<  >  >>|"
    tput cup $((OFFSET + 3)) $(( (TERM_COLS / 2) - (${#CONTROLS} / 2) ))
    echo -e "${COLOR_ACCENT}${CONTROLS}${RESET}"

    sleep 1
done
