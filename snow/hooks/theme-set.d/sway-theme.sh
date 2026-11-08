#!/bin/bash
# Theme-set hook: secondary reload in case restart-hyprctl missed anything
# Bar colors and wallpaper are handled by omarchy-restart-hyprctl
# This hook handles a final sway reload as a safety net
SWAY_SOCK=$(find /run/user/$(id -u) -name "sway-ipc.*" -type s 2>/dev/null | head -1)
[ -n "$SWAY_SOCK" ] && SWAYSOCK="$SWAY_SOCK" swaymsg reload 2>/dev/null
exit 0
