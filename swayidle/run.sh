#!/bin/bash

# swayidle configuration matching current hypridle behavior
# 10 minutes timeout for display off
# will (intentionally) NEVER sleep or suspend

# DRY: Extract swaync restart command
RESUME_CMD='hyprctl dispatch dpms on && pkill swaync; sleep 0.5 && swaync -c ~/.config/hypr/swaync/config.json -s ~/.config/hypr/swaync/$(~/.config/hypr/scripts/get-theme.sh).css'

swayidle -w \
    timeout 580 'swaylock -C ~/.config/hypr/swaylock/config' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume "$RESUME_CMD" \
    before-sleep 'swaylock -C ~/.config/hypr/swaylock/config' \
    after-resume "$RESUME_CMD"
