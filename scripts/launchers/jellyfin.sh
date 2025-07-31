#!/bin/bash

# Parse arguments
WIDTH=${1:-1822}
HEIGHT=${2:-1367}

# Check if Jellyfin window already exists
JELLYFIN_ADDRESS=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.github.iwalton3.jellyfin-media-player") | .address' | head -n1)

if [ -n "$JELLYFIN_ADDRESS" ]; then
    # Window exists, just focus it
    hyprctl dispatch focuswindow address:$JELLYFIN_ADDRESS
else
    # Window doesn't exist, launch and position it
    jellyfinmediaplayer &

    # Wait for jellyfin window to appear
    while ! hyprctl clients -j | jq -e '.[] | select(.class == "com.github.iwalton3.jellyfin-media-player")' > /dev/null; do
        sleep 0.1
    done

    sleep 0.2  # Small delay for window to be properly focused

    # Move window left many times
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l
    hyprctl dispatch movewindow l

    sleep 0.2

    # Resize to
    hyprctl dispatch resizeactive exact $WIDTH $HEIGHT
fi