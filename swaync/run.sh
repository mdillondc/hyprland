#!/bin/bash
pkill swaync
swaync -c ~/.config/hypr/swaync/config.json -s ~/.config/hypr/swaync/$(~/.config/hypr/scripts/get-theme.sh).css &
