#!/bin/bash

# Google Messages launcher script
# Focuses existing window if open, otherwise launches new instance

# Look for existing Google Messages window using the correct class name
messages_address=$(hyprctl clients -j | jq -r '.[] | select(.class == "chrome-messages.google.com__web-Default") | .address' | head -n1)

if [ -n "$messages_address" ] && [ "$messages_address" != "null" ]; then
    # Focus the existing Google Messages window
    hyprctl dispatch focuswindow address:$messages_address
else
    # Launch new Google Messages instance
    chromium --ozone-platform=wayland --enable-features=UseOzonePlaform --app=https://messages.google.com/web --disable-infobars &
fi