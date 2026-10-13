#!/usr/bin/env bash
CONFIG="$HOME/.config/sway/codeforces.json"
CACHE="/tmp/codeforces_waybar_cache.json"

current="$(python3 -c "import json, os; print(json.load(open('$CONFIG')).get('handle','')) if os.path.exists('$CONFIG') else print('')" 2>/dev/null)"
new_handle="$(echo "" | rofi -dmenu -p "Codeforces Handle" -mesg "Current: ${current:-none}" -theme ~/.config/rofi/launcher.rasi 2>/dev/null || true)"

if [[ -n "$new_handle" ]]; then
    new_handle="${new_handle// /}"
    echo "{\"handle\": \"$new_handle\"}" > "$CONFIG"
    rm -f "$CACHE"
    pkill -RTMIN+9 waybar 2>/dev/null || true
fi
