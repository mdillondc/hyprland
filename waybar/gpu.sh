#!/bin/bash
# GPU usage monitor showing utilization% / memory% / temp°C

if command -v nvidia-smi >/dev/null 2>&1; then
    # Get GPU utilization percentage
    gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

    # Get memory used and total in MiB
    memory_info=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)

    # Get GPU temperature
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

    if [[ -n "$gpu_util" && -n "$memory_info" && -n "$gpu_temp" ]]; then
        # Parse memory values
        mem_used=$(echo "$memory_info" | cut -d',' -f1 | tr -d ' ')
        mem_total=$(echo "$memory_info" | cut -d',' -f2 | tr -d ' ')

        # Calculate memory percentage
        if [[ "$mem_total" -gt 0 ]]; then
            mem_percent=$(( (mem_used * 100) / mem_total ))
        else
            mem_percent="N/A"
        fi

        # echo "${gpu_util}% ${mem_percent}% ${gpu_temp}°"
        echo "${mem_percent}% (${gpu_temp}°)"
    fi
else
    # Try Intel integrated graphics
    # Look for Intel GPU in /sys/class/drm/
    intel_card=""
    for card in /sys/class/drm/card*; do
        if [[ -f "$card/device/vendor" ]]; then
            vendor=$(cat "$card/device/vendor" 2>/dev/null)
            if [[ "$vendor" == "0x8086" ]]; then  # Intel vendor ID
                intel_card="$card"
                break
            fi
        fi
    done

    if [[ -n "$intel_card" ]]; then
        # Try to get GPU utilization using intel_gpu_top
        gpu_util=""
        if command -v intel_gpu_top >/dev/null 2>&1; then
            # Get GPU utilization (timeout after 2 seconds)
            gpu_util=$(timeout 2s intel_gpu_top 2>/dev/null | tail -n +3 | head -1 | awk '{printf "%.0f", $7}')
        fi

        # Try to get temperature from hwmon
        temp=""
        for hwmon in /sys/class/hwmon/hwmon*; do
            if [[ -f "$hwmon/name" ]]; then
                hwmon_name=$(cat "$hwmon/name" 2>/dev/null)
                if [[ "$hwmon_name" == "coretemp" ]] || [[ "$hwmon_name" == "i915" ]]; then
                    for temp_file in "$hwmon"/temp*_input; do
                        if [[ -f "$temp_file" ]]; then
                            temp_raw=$(cat "$temp_file" 2>/dev/null)
                            if [[ -n "$temp_raw" && "$temp_raw" -gt 10000 ]]; then  # Reasonable temperature check
                                temp=$((temp_raw / 1000))  # Convert millidegrees to degrees
                                break 2
                            fi
                        fi
                    done
                fi
            fi
        done

        # Format output
        if [[ -n "$gpu_util" && -n "$temp" ]]; then
            echo "${gpu_util}% (${temp}°)"
        elif [[ -n "$temp" ]]; then
            echo "Intel (${temp}°)"
        elif [[ -n "$gpu_util" ]]; then
            echo "Intel ${gpu_util}%"
        else
            echo "Intel GPU"
        fi
    else
        echo "No GPU"
    fi
fi