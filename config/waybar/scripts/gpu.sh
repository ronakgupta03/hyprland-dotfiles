#!/usr/bin/env bash
# GPU usage for waybar, with temperature and VRAM in the tooltip, as JSON.

# 1. Try AMD sysfs first
dev=""
for d in /sys/class/drm/card*/device; do
    [[ -r "$d/gpu_busy_percent" ]] && { dev="$d"; break; }
done

if [[ -n "$dev" ]]; then
    busy=$(<"$dev/gpu_busy_percent")
    temp=0
    for t in "$dev"/hwmon/hwmon*/temp1_input; do
        [[ -r "$t" ]] && temp=$(( $(<"$t") / 1000 ))
        break
    done
    used=$(( $(<"$dev/mem_info_vram_used") / 1048576 ))
    total=$(( $(<"$dev/mem_info_vram_total") / 1048576 ))
    class=ok; (( temp >= 90 )) && class=hot
    printf '{"text":"󰢮 %s%%","tooltip":"GPU %s%%  ·  %s°C\\nVRAM %s / %s MiB","class":"%s"}\n' \
        "$busy" "$busy" "$temp" "$used" "$total" "$class"
    exit 0
fi

# 2. NVIDIA fallback
if command -v nvidia-smi >/dev/null 2>&1; then
    out=$(timeout 1.5 nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
    if [[ -n "$out" ]]; then
        busy=$(echo "$out" | awk -F',' '{print $1}' | tr -d ' ')
        temp=$(echo "$out" | awk -F',' '{print $2}' | tr -d ' ')
        used=$(echo "$out" | awk -F',' '{print $3}' | tr -d ' ')
        total=$(echo "$out" | awk -F',' '{print $4}' | tr -d ' ')
        class=ok; (( temp >= 85 )) && class=hot
        printf '{"text":"󰢮 %s%%","tooltip":"GPU %s%%  ·  %s°C\\nVRAM %s / %s MiB","class":"%s"}\n' \
            "$busy" "$busy" "$temp" "$used" "$total" "$class"
        exit 0
    fi
fi

echo '{"text":""}'
exit 0
