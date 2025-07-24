#!/bin/bash

# Simple window switcher for Hyprland
# Cycles through all windows across workspaces

# Get all windows with their info
windows=$(hyprctl clients -j)

# Get currently focused window
current_window=$(hyprctl activewindow -j)
current_address=$(echo "$current_window" | jq -r '.address')

# Extract window addresses in order
addresses=($(echo "$windows" | jq -r '.[].address'))

# Find current window index
current_index=-1
for i in "${!addresses[@]}"; do
    if [[ "${addresses[$i]}" == "$current_address" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next window index
if [[ $current_index -eq -1 ]] || [[ ${#addresses[@]} -eq 0 ]]; then
    exit 1
fi

# Determine direction (forward by default, backward if --reverse)
if [[ "$1" == "--reverse" ]]; then
    next_index=$(( (current_index - 1 + ${#addresses[@]}) % ${#addresses[@]} ))
else
    next_index=$(( (current_index + 1) % ${#addresses[@]} ))
fi

# Get next window address
next_address=${addresses[$next_index]}

# Focus the next window
hyprctl dispatch focuswindow "address:$next_address"