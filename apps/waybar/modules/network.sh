#!/bin/bash
# Network speed monitor in MB/s

get_network_interface() {
    # Get the default route interface
    ip route | grep '^default' | head -n1 | awk '{print $5}' 2>/dev/null
}

get_network_speeds() {
    local interface="$1"
    local cache_file="/tmp/waybar_network_$interface"

    if [[ -z "$interface" ]]; then
        echo "0.00 0.00"
        return
    fi

    # Read current network stats and timestamp
    local current_time=$(date +%s)
    local current_rx=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
    local current_tx=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)

    # Read previous stats from cache
    if [[ -f "$cache_file" ]]; then
        local prev_data=$(cat "$cache_file" 2>/dev/null)
        local prev_time=$(echo "$prev_data" | cut -d' ' -f1)
        local prev_rx=$(echo "$prev_data" | cut -d' ' -f2)
        local prev_tx=$(echo "$prev_data" | cut -d' ' -f3)

        # Calculate time difference
        local time_diff=$((current_time - prev_time))

        if [[ "$time_diff" -gt 0 ]]; then
            # Calculate bytes per second
            local rx_speed=$(( (current_rx - prev_rx) / time_diff ))
            local tx_speed=$(( (current_tx - prev_tx) / time_diff ))

            # Convert to MB/s (divide by 1024*1024)
            local rx_mb=$(echo "scale=1; $rx_speed / 1048576" | bc 2>/dev/null || echo "0.0")
            local tx_mb=$(echo "scale=1; $tx_speed / 1048576" | bc 2>/dev/null || echo "0.0")

            # Format with conditional decimals
            if (( $(echo "$rx_mb > 9.9" | bc -l) )); then
                local rx_mb_int=$(echo "$rx_mb / 1" | bc 2>/dev/null || echo "0")
                if [[ "$rx_mb_int" -lt 10 ]]; then
                    rx_display=$(printf "%02d" "$rx_mb_int")
                else
                    rx_display=$(printf "%d" "$rx_mb_int")
                fi
            else
                rx_display=$(printf "%.1f" "$rx_mb")
            fi

            if (( $(echo "$tx_mb > 9.9" | bc -l) )); then
                local tx_mb_int=$(echo "$tx_mb / 1" | bc 2>/dev/null || echo "0")
                if [[ "$tx_mb_int" -lt 10 ]]; then
                    tx_display=$(printf "%02d" "$tx_mb_int")
                else
                    tx_display=$(printf "%d" "$tx_mb_int")
                fi
            else
                tx_display=$(printf "%.1f" "$tx_mb")
            fi
        else
            rx_display="0.0"
            tx_display="0.0"
        fi
    else
        # First run, no previous data
        rx_display="0.0"
        tx_display="0.0"
    fi

    # Store current stats for next run
    echo "$current_time $current_rx $current_tx" > "$cache_file"

    echo "$rx_display $tx_display"
}

# Main execution
interface=$(get_network_interface)
speeds=$(get_network_speeds "$interface")
rx_display=$(echo "$speeds" | cut -d' ' -f1)
tx_display=$(echo "$speeds" | cut -d' ' -f2)

echo "󰁅 ${rx_display} 󰁝 ${tx_display}"
