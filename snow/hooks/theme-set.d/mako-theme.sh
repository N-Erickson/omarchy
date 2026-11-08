#!/bin/bash
THEME_PATH="$HOME/.local/state/omarchy/current/theme"
COLORS="$THEME_PATH/colors.toml"
MAKO_CONFIG="$HOME/.config/mako/config"

[ -f "$COLORS" ] || exit 0
[ -f "$MAKO_CONFIG" ] || exit 0

get_color() {
    grep "^$1" "$COLORS" 2>/dev/null | head -1 | sed "s/.*= *\"\(.*\)\"/\1/"
}

BG=$(get_color "background")
FG=$(get_color "foreground")
ACCENT=$(get_color "accent")
MUTED=$(get_color "muted")

[ -z "$BG" ] && exit 0

sed -i "s/^background-color=.*/background-color=${BG}ee/" "$MAKO_CONFIG"
sed -i "s/^text-color=.*/text-color=${FG}/" "$MAKO_CONFIG"
sed -i "s/^border-color=.*/border-color=${ACCENT}/" "$MAKO_CONFIG"
sed -i "s/^progress-color=.*/progress-color=over ${ACCENT}40/" "$MAKO_CONFIG"

makoctl reload 2>/dev/null || true
