#!/bin/bash
pkill swaync
sleep 1
swaync -c ~/.config/hypr/apps/swaync/config.json -s ~/.config/hypr/apps/swaync/$(~/.config/hypr/scripts/theme/get-theme.sh).css