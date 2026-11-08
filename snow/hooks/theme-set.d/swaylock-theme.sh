#!/bin/bash
THEME_PATH="$HOME/.local/state/omarchy/current/theme"
COLORS="$THEME_PATH/colors.toml"
SWAYLOCK_CONFIG="$HOME/.config/swaylock/config"

[ -f "$COLORS" ] || exit 0
[ -f "$SWAYLOCK_CONFIG" ] || exit 0

get_color() {
    grep "^$1" "$COLORS" 2>/dev/null | head -1 | sed "s/.*= *\"\(.*\)\"/\1/" | sed "s/#//"
}

BG=$(get_color "background")
FG=$(get_color "foreground")
ACCENT=$(get_color "accent")
MUTED=$(get_color "muted")
RED=$(get_color "red")
GREEN=$(get_color "green")
YELLOW=$(get_color "yellow")
BRIGHT_FG=$(get_color "bright_foreground")

[ -z "$BG" ] && exit 0

sed -i "s/^color=.*/color=${BG}/" "$SWAYLOCK_CONFIG"
sed -i "s/^inside-color=.*/inside-color=${BG}ee/" "$SWAYLOCK_CONFIG"
sed -i "s/^inside-clear-color=.*/inside-clear-color=${BG}ee/" "$SWAYLOCK_CONFIG"
sed -i "s/^inside-ver-color=.*/inside-ver-color=${BG}ee/" "$SWAYLOCK_CONFIG"
sed -i "s/^inside-wrong-color=.*/inside-wrong-color=${BG}ee/" "$SWAYLOCK_CONFIG"
sed -i "s/^ring-color=.*/ring-color=${ACCENT}/" "$SWAYLOCK_CONFIG"
sed -i "s/^ring-clear-color=.*/ring-clear-color=${YELLOW}/" "$SWAYLOCK_CONFIG"
sed -i "s/^ring-ver-color=.*/ring-ver-color=${GREEN}/" "$SWAYLOCK_CONFIG"
sed -i "s/^ring-wrong-color=.*/ring-wrong-color=${RED}/" "$SWAYLOCK_CONFIG"
sed -i "s/^text-color=.*/text-color=${BRIGHT_FG:-$FG}/" "$SWAYLOCK_CONFIG"
sed -i "s/^text-clear-color=.*/text-clear-color=${YELLOW}/" "$SWAYLOCK_CONFIG"
sed -i "s/^text-ver-color=.*/text-ver-color=${GREEN}/" "$SWAYLOCK_CONFIG"
sed -i "s/^text-wrong-color=.*/text-wrong-color=${RED}/" "$SWAYLOCK_CONFIG"
