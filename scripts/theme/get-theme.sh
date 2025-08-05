#!/bin/bash

# Extract theme from hyprland.conf
# This script is used by various components (e.g in waybar) to get the current theme

# Theme variable is set here
HYPR_CONFIG="$HOME/.config/hypr/conf/look.conf"

# Extract theme variable, e.g. "gruvbox"
theme=$(grep '^\$theme =' "$HYPR_CONFIG" | cut -d'=' -f2 | tr -d ' ')

# Output the theme name
echo "$theme"