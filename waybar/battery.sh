#!/bin/bash
# Battery monitor showing percentage and status

get_battery_info() {
    # Check if battery exists, exit silently if not
    if [[ ! -d "/sys/class/power_supply/BAT0" ]]; then
        return
    fi

    local capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
    local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

    # Choose icon based on status and capacity
    local icon=""
    case "$status" in
        "Charging")
            icon="󰂄"
            ;;
        "Discharging")
            if [[ $capacity -ge 80 ]]; then
                icon="󰂂"
            elif [[ $capacity -ge 60 ]]; then
                icon="󰂀"
            elif [[ $capacity -ge 40 ]]; then
                icon="󰁾"
            elif [[ $capacity -ge 20 ]]; then
                icon="󰁼"
            else
                icon="󰁺"
            fi
            ;;
        "Full")
            icon="󰁹"
            ;;
        *)
            icon="󰂑"
            ;;
    esac

    echo "$icon $capacity%"
}

get_battery_info
