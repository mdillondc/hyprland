#!/bin/bash

# swayidle configuration matching current hypridle behavior
# 10 minutes timeout for display off
# will (intentionally) NEVER sleep or suspend

# DRY: Extract swaync restart command
RESUME_CMD='hyprctl dispatch dpms on && ~/.config/hypr/apps/swaync/run.sh'

swayidle -w \
    timeout 580 'swaylock -C ~/.config/hypr/apps/swaylock/config' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume "$RESUME_CMD" \
    before-sleep 'swaylock -C ~/.config/hypr/apps/swaylock/config' \
    after-resume "$RESUME_CMD"
