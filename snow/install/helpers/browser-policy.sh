#!/bin/bash
# Stub for Snow — no Chromium-based browsers installed
# These variables and functions are sourced by omarchy-theme-set-browser

BROWSER_POLICY_DEFAULT_COLOR="#1a1b26"
BROWSER_POLICY_MANAGED_DIRS=()

browser_policy_theme_hex() {
    local input="${1:-}"
    if [[ -z "$input" ]]; then
        echo "$BROWSER_POLICY_DEFAULT_COLOR"
    else
        echo "#$input"
    fi
}
