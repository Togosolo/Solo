#!/usr/bin/env bash

WALL_DIR="/home/solo/Imagens/Walls/"

list_walls() {
    shopt -s nullglob
    for wall in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
        [ -f "$wall" ] || continue
        echo -en "$(basename "$wall")\0icon\x1f$wall\n"
    done | sort -V
}

CHOICE=$(list_walls | rofi -dmenu -i -p "󰸉 Wallpapers:" \
    -show-icons \
    -theme-str 'element-icon { size: 120px; } listview { columns: 3; lines: 2; } element { orientation: vertical; }')

#Se cancelar o rofi, sai
[ -z "$CHOICE" ] && exit 0

FULL_PATH="$WALL_DIR/$CHOICE"

#Cria link simbólico para o wallpaper atual
ln -sf "$FULL_PATH" "$WALL_DIR/current"

#Aplica wallpaper
awww img --transition-type grow --transition-fps 180 --transition-step 20 "$FULL_PATH"

#Gera tema com matugen (dark)
matugen image "$FULL_PATH" --config "/home/solo/.config/matugen/config.toml" --mode dark --type scheme-content --source-color-index 0

#Recarrega Hyprland e Waybar
hyprctl reload
pkill waybar -SIGUSR2
