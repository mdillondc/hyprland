#!/bin/bash

# Volume control script that unmutes before changing volume
# Usage: volume-control.sh [up|down|mute]

case "$1" in
    "up")
        # Unmute first, then increase volume
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.5
        ;;
    "down")
        # Unmute first, then decrease volume
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    "mute")
        # Toggle mute
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 [up|down|mute]"
        exit 1
        ;;
esac

# Get current volume and mute status for notification
VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
if echo "$VOLUME_INFO" | grep -q "MUTED"; then
    VOLUME_TEXT="Muted"
else
    VOLUME_PERCENT=$(echo "$VOLUME_INFO" | awk '{print int($2*100)"%"}')
    VOLUME_TEXT="$VOLUME_PERCENT"
fi

# Send notification
notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume" "$VOLUME_TEXT"