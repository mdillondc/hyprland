#!/bin/bash

hyprctl reload
~/.config/hypr/scripts/system/set-resolution.sh &
~/.config/hypr/apps/waybar/run.sh &
~/.config/hypr/apps/swaync/run.sh &