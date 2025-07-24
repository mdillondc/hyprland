#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Sync/wallpapers/huge"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprland/hyprpaper.conf"

# Check if wallpaper directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    exit 1
fi

# Get all image files from the wallpaper directory
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null)

# Check if any wallpapers were found
if [[ ${#wallpapers[@]} -eq 0 ]]; then
    echo "Error: No image files found in $WALLPAPER_DIR"
    exit 1
fi

# Select a random wallpaper using shuf
if command -v shuf >/dev/null 2>&1; then
    random_wallpaper=$(printf '%s\n' "${wallpapers[@]}" | shuf -n1)
fi

echo "Selected wallpaper: $(basename "$random_wallpaper")"

# Construct path using tilde for hyprpaper.conf
wallpaper_for_config="~/Sync/wallpapers/huge/$(basename "$random_wallpaper")"

# Update hyprpaper.conf
cat > "$HYPRPAPER_CONF" << EOF
preload = $wallpaper_for_config
wallpaper = ,$wallpaper_for_config
splash = false
EOF

echo "Updated hyprpaper.conf"

# Kill hyprpaper if it's running
if pgrep hyprpaper > /dev/null; then
    echo "Stopping hyprpaper..."
    killall hyprpaper

    # Force kill if still running
    if pgrep hyprpaper > /dev/null; then
        echo "Force killing hyprpaper..."
        killall -9 hyprpaper
        sleep 0.2
    fi
fi

# Start hyprpaper with new configuration
echo "Starting hyprpaper..."
hyprpaper -c ~/.config/hypr/hyprland/hyprpaper.conf &

# Give it a moment to start
sleep 0.5

echo "Wallpaper changed successfully!"