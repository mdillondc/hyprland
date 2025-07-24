#!/bin/bash

# swayidle configuration matching current hypridle behavior
# 10 minutes timeout for display off
# will (intentionally) NEVER sleep or suspend

swayidle -w \
    timeout 580 'swaylock -C ~/.config/hypr/swaylock/config' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock -C ~/.config/hypr/swaylock/config' \
    after-resume 'hyprctl dispatch dpms on'
