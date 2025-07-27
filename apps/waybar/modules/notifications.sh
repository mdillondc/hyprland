#!/bin/bash
# SwayNC notification count for waybar

# Function to get notification count
get_notification_count() {
    # Check if swaync is running
    if ! pgrep swaync >/dev/null 2>&1; then
        echo "0"
        return
    fi

    # Get notification count from swaync-client
    local count=$(swaync-client --count 2>/dev/null)

    # Validate the count is a number
    if [[ "$count" =~ ^[0-9]+$ ]]; then
        echo "$count"
    else
        echo "0"
    fi
}

# Get and output notification count
notification_count=$(get_notification_count)
echo "$notification_count"