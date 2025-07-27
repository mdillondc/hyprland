#!/bin/bash

# Kill any existing waybar processes
pkill waybar
sleep 1

# Start waybar
waybar -c ~/.config/hypr/apps/waybar/config.jsonc -s ~/.config/hypr/apps/waybar/$(~/.config/hypr/scripts/theme/get-theme.sh).css