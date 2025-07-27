#!/bin/bash

echo "Reloading Hyprland configuration..."

# Reload Hyprland config with error checking
if ! hyprctl reload; then
    echo "❌ Failed to reload Hyprland config"
    exit 1
fi

echo "Hyprland config reloaded"

# Set resolution and wait a moment for it to apply
echo "Setting resolution..."
if ~/.config/hypr/scripts/system/set-resolution.sh; then
    echo "Resolution set"
else
    echo "Resolution script failed"
fi

# Restart services with brief delays to avoid conflicts
echo "Restarting waybar..."
~/.config/hypr/apps/waybar/run.sh &
WAYBAR_PID=$!

sleep 0.5

echo "Restarting swaync..."
~/.config/hypr/apps/swaync/run.sh &
SWAYNC_PID=$!

echo "Reload complete"
