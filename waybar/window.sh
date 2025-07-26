#!/bin/bash
# Dynamic window title with resolution-based max-length

get_window_title() {
    # Get window title using hyprctl, fallback to "Desktop" if empty
    hyprctl activewindow -j | jq -r '.title // "Desktop"' 2>/dev/null || echo "Desktop"
}

get_max_length() {
    # Get screen width from wlr-randr (current resolution)
    local width=$(wlr-randr 2>/dev/null | grep -E '^\s+[0-9]+x[0-9]+.*current' | head -1 | sed 's/^\s*//' | cut -d'x' -f1)

    # Set max-length based on screen width
    if [[ $width -ge 3840 ]]; then
        echo 150  # Ultrawide
    elif [[ $width -ge 2560 ]]; then
        echo 80  # Higher than standard
    else
        echo 50  # Standard/laptop (< standard)
    fi
}

truncate_title() {
    local title="$1"
    local max_length="$2"

    if [[ ${#title} -gt $max_length ]]; then
        echo "${title:0:$max_length}..."
    else
        echo "$title"
    fi
}

# Main execution
window_title=$(get_window_title)
max_length=$(get_max_length)
truncated_title=$(truncate_title "$window_title" "$max_length")

echo "$truncated_title"