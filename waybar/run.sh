#!/bin/bash

# Kill any existing waybar processes
pkill waybar

# Start waybar
theme=$(~/.config/hypr/scripts/get-theme.sh)
waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/$theme.css &