#!/bin/bash

# Resolution configuration script for Hyprland
# Sets monitor resolution based on hostname

# Get the current hostname
HOSTNAME=$(hostname)

# Check if hostname contains "desktop"
if [[ "$HOSTNAME" == *"desktop"* ]]; then
    echo "Desktop detected (hostname: $HOSTNAME). Setting high refresh rate monitor configuration..."
    hyprctl keyword monitor "DP-2,5120x1440@239.761002,auto,1.0" # Attempting to set preferred resolution will fail for my display, hence forcing the correct resolution
else
    echo "Non-desktop system detected (hostname: $HOSTNAME). Using preferred monitor configuration..."
    hyprctl keyword monitor ",preferred,auto,1.0" # Use preferred resolution for display
fi

# Log the current monitor configuration
echo "Current monitor configuration:"
hyprctl monitors
