#!/usr/bin/env bash
# Brightness presets and settings dialog for Waybar
set -euo pipefail

DEV="nvidia_0"
if [[ -d "/sys/class/backlight/$DEV" ]]; then
    B_CMD=(brightnessctl -d "$DEV")
else
    B_CMD=(brightnessctl)
fi

# If arguments are passed (e.g. +5% or 5%-), apply directly
if [[ $# -gt 0 ]]; then
    "${B_CMD[@]}" set "$@"
    exit 0
fi

# Fetch current percentage
CURRENT=$("${B_CMD[@]}" info 2>/dev/null | grep -oP '\(\K[0-9]+(?=%\))' || echo "50")

OPTIONS=$(cat <<EOF
󰃠  100%   Max
󰃟   75%   Bright
󰃟   50%   Balanced
󰃝   25%   Low
󰃞   10%   Dim
󰍹  Displays settings
EOF
)

CHOSEN=$(printf '%s\n' "$OPTIONS" | rofi -dmenu -i -p "󰃠  Brightness (${CURRENT}%)" -theme ~/.config/rofi/menu.rasi || true)

case "$CHOSEN" in
    *100%*) "${B_CMD[@]}" set 100% ;;
    *75%*)  "${B_CMD[@]}" set 75% ;;
    *50%*)  "${B_CMD[@]}" set 50% ;;
    *25%*)  "${B_CMD[@]}" set 25% ;;
    *10%*)  "${B_CMD[@]}" set 10% ;;
    *Displays*)
        if [[ -x "$HOME/.local/bin/rice-settings" ]]; then
            "$HOME/.local/bin/rice-settings" displays
        fi
        ;;
    "")     exit 0 ;;
    *)
        # If user typed a custom number (e.g. 40 or 40%)
        NUM=$(echo "$CHOSEN" | grep -oP '^[0-9]+' || true)
        if [[ -n "$NUM" ]]; then
            "${B_CMD[@]}" set "${NUM}%"
        fi
        ;;
esac
