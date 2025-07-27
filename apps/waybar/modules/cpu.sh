#!/bin/bash
# CPU usage monitor showing utilization% (temp°C)

# Function to get CPU usage percentage
get_cpu_usage() {
    # Read /proc/stat twice with a small delay to calculate usage
    local cpu1=($(head -n1 /proc/stat))
    sleep 0.1
    local cpu2=($(head -n1 /proc/stat))

    # Calculate total and idle time for both readings
    local idle1=$((${cpu1[4]} + ${cpu1[5]}))
    local total1=0
    for value in "${cpu1[@]:1}"; do
        total1=$((total1 + value))
    done

    local idle2=$((${cpu2[4]} + ${cpu2[5]}))
    local total2=0
    for value in "${cpu2[@]:1}"; do
        total2=$((total2 + value))
    done

    # Calculate usage percentage
    local idle_diff=$((idle2 - idle1))
    local total_diff=$((total2 - total1))

    if [[ $total_diff -gt 0 ]]; then
        local usage=$((100 * (total_diff - idle_diff) / total_diff))
        echo "$usage"
    else
        echo "0"
    fi
}

# Function to get CPU temperature
get_cpu_temp() {
    local temp=""

    # Try different temperature sources
    # Method 1: Try thermal zones
    for thermal_zone in /sys/class/thermal/thermal_zone*/temp; do
        if [[ -r "$thermal_zone" ]]; then
            local zone_type=$(cat "${thermal_zone%/*}/type" 2>/dev/null)
            # Look for CPU-related thermal zones
            if [[ "$zone_type" =~ (cpu|CPU|x86_pkg_temp|coretemp|k10temp) ]]; then
                local temp_raw=$(cat "$thermal_zone" 2>/dev/null)
                if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
                    temp=$((temp_raw / 1000))
                    break
                fi
            fi
        fi
    done

    # Method 2: Try hwmon if thermal zones didn't work
    if [[ -z "$temp" ]]; then
        for hwmon_temp in /sys/class/hwmon/hwmon*/temp*_input; do
            if [[ -r "$hwmon_temp" ]]; then
                local hwmon_name=$(cat "${hwmon_temp%/*}/name" 2>/dev/null)
                # Look for CPU-related hwmon sensors
                if [[ "$hwmon_name" =~ (coretemp|k10temp|cpu|CPU) ]]; then
                    local temp_raw=$(cat "$hwmon_temp" 2>/dev/null)
                    if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
                        temp=$((temp_raw / 1000))
                        break
                    fi
                fi
            fi
        done
    fi

    # Method 3: Try sensors command if available
    if [[ -z "$temp" ]] && command -v sensors >/dev/null 2>&1; then
        temp=$(sensors 2>/dev/null | grep -E "(Package id|Core 0|Tctl)" | head -n1 | grep -oE '\+[0-9]+\.[0-9]+°C' | grep -oE '[0-9]+' | head -n1)
    fi

    echo "${temp:-N/A}"
}

# Get CPU usage and temperature
cpu_usage=$(get_cpu_usage)
cpu_temp=$(get_cpu_temp)

# Format output similar to GPU script
if [[ -n "$cpu_usage" ]]; then
    if [[ "$cpu_temp" != "N/A" ]]; then
        echo "${cpu_usage}% (${cpu_temp}°)"
    else
        echo "${cpu_usage}%"
    fi
else
    echo "N/A"
fi