#!/bin/bash

# This script sets up the following layout on workspace 1 on login.
# It assumes dwindle layout.
# 
# ┌─────┬────────────┬──────────┐
# │mocp │easyeffects | messages │
# │     │pamix       │          │
# └─────┴────────────┴──────────┘
# 
# It's hacky AF, but it works on my 5120x1440 display.
# 
# I don't except this to be transferable, and might even
# break on other displays with the same resolution.
# 
# I'm sure there is a better way to do this. If you know how,
# please let me know on https://github.com/mdillondc/hyprland/issues
# I would be very grateful!

APP_1="mocp"
APP_2="easyeffects"
APP_3="pamix"
APP_4="messages"

# App definitions - startup commands and window classes
declare -A APP_COMMANDS=(
    ["mocp"]="ghostty --title=mocp -e mocp"
    ["pamix"]="ghostty --title=pamix -e pamix"
    ["easyeffects"]="/usr/bin/easyeffects"
    ["messages"]="chromium --ozone-platform=wayland --enable-features=UseOzonePlaform --app=https://messages.google.com/web --disable-infobars"
)

declare -A APP_CLASSES=(
    ["mocp"]="com.mitchellh.ghostty"
    ["pamix"]="com.mitchellh.ghostty"
    ["easyeffects"]="com.github.wwmm.easyeffects"
    ["messages"]="chrome-messages.google.com__web-Default"
)

declare -A APP_TITLES=(
    ["mocp"]="mocp"
    ["pamix"]="pamix"
    ["easyeffects"]=""
    ["messages"]=""
)

echo "Setting up audio workspace with positioning control..."
echo "Target layout: $APP_1 | $APP_2 | $APP_3 | $APP_4"

# Function to wait for a specific window to appear
wait_for_window() {
    local class="$1"
    local title_contains="$2"
    local timeout="${3:-15}"
    local count=0

    echo "Waiting for window: class=$class, title contains '$title_contains'"

    while [ $count -lt $timeout ]; do
        if [ -n "$title_contains" ]; then
            # Check for both class and title
            if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\" and (.title | test(\"$title_contains\"; \"i\")))" > /dev/null 2>&1; then
                echo "Window found: $class with title containing '$title_contains'"
                return 0
            fi
        else
            # Check for class only
            if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\")" > /dev/null 2>&1; then
                echo "Window found: $class"
                return 0
            fi
        fi
        sleep 0.5
        ((count++))
    done
    echo "Warning: Window not found within timeout: $class"
    return 1
}

# Function to get window address
get_window_address() {
    local class="$1"
    local title_contains="$2"

    if [ -n "$title_contains" ]; then
        hyprctl clients -j | jq -r ".[] | select(.class == \"$class\" and (.title | test(\"$title_contains\"; \"i\"))) | .address" | head -1
    else
        hyprctl clients -j | jq -r ".[] | select(.class == \"$class\") | .address" | head -1
    fi
}

# Function to get window position in workspace (X coordinate)
get_window_x() {
    local address="$1"
    hyprctl clients -j | jq -r ".[] | select(.address == \"$address\") | .at[0]"
}

# Function to get window position in workspace (Y coordinate)
get_window_y() {
    local address="$1"
    hyprctl clients -j | jq -r ".[] | select(.address == \"$address\") | .at[1]"
}

# Start applications sequentially on workspace 1
echo "Starting applications sequentially for predictable dwindle layout..."

# Start App 1 and wait for it to be ready
echo "Starting $APP_1..."
hyprctl dispatch exec "[workspace 1 silent] ${APP_COMMANDS[$APP_1]}"
echo "Waiting for $APP_1 window..."
wait_for_window "${APP_CLASSES[$APP_1]}" "${APP_TITLES[$APP_1]}" 15
col1_ready=$?

# Start App 2 and wait for it to be ready
echo "Starting $APP_2..."
hyprctl dispatch exec "[workspace 1 silent] ${APP_COMMANDS[$APP_2]}"
echo "Waiting for $APP_2 window..."
wait_for_window "${APP_CLASSES[$APP_2]}" "${APP_TITLES[$APP_2]}" 15
col2_ready=$?

# Start App 3 and wait for it to be ready
echo "Starting $APP_3..."
hyprctl dispatch exec "[workspace 1 silent] ${APP_COMMANDS[$APP_3]}"
echo "Waiting for $APP_3 window..."
wait_for_window "${APP_CLASSES[$APP_3]}" "${APP_TITLES[$APP_3]}" 15
col3_ready=$?

# Start App 4 and wait for it to be ready
echo "Starting $APP_4..."
hyprctl dispatch exec "[workspace 1 silent] ${APP_COMMANDS[$APP_4]}"
echo "Waiting for $APP_4 window..."
wait_for_window "${APP_CLASSES[$APP_4]}" "${APP_TITLES[$APP_4]}" 15
col4_ready=$?

echo "All applications started sequentially with known dwindle order"

# Proceed with positioning if at least basic windows are ready
if [ $col1_ready -eq 0 ] && [ $col2_ready -eq 0 ] && [ $col3_ready -eq 0 ]; then
    echo "Arranging windows in 4-column layout: $APP_1 | $APP_2 | $APP_3 | $APP_4"

    # Get window addresses
    mocp_addr=$(get_window_address "${APP_CLASSES[$APP_1]}" "${APP_TITLES[$APP_1]}")
    easyeffects_addr=$(get_window_address "${APP_CLASSES[$APP_2]}" "${APP_TITLES[$APP_2]}")
    pamix_addr=$(get_window_address "${APP_CLASSES[$APP_3]}" "${APP_TITLES[$APP_3]}")

    if [ $col4_ready -eq 0 ]; then
        messages_addr=$(get_window_address "${APP_CLASSES[$APP_4]}" "${APP_TITLES[$APP_4]}")
    fi

    echo "Window addresses:"
    echo "  $APP_1: $mocp_addr"
    echo "  $APP_2: $easyeffects_addr"
    echo "  $APP_3: $pamix_addr"
    [ $col4_ready -eq 0 ] && echo "  $APP_4: $messages_addr"

    # Check if we have valid addresses
    if [ -n "$mocp_addr" ] && [ -n "$easyeffects_addr" ] && [ -n "$pamix_addr" ]; then
        echo "Using hacky dwindle solution to create 4-column layout..."

        # Simple hack: Move messages up to create 4th column
        # Known layout: mocp | pamix | easyeffects
        #               msgs
        # Target:       mocp | pamix | easyeffects | messages
        if [ $col4_ready -eq 0 ] && [ -n "$messages_addr" ]; then
            echo "Moving $APP_4 right three times to create 4th column..."
            hyprctl dispatch focuswindow "address:$messages_addr"
            hyprctl dispatch movewindow r
            hyprctl dispatch movewindow r
            hyprctl dispatch movewindow r
        fi

        # Focus easyeffects and move it left
        echo "Moving easyeffects left..."
        hyprctl dispatch focuswindow "address:$easyeffects_addr"
        hyprctl dispatch movewindow l

        echo "Dwindle layout arrangement complete - 4-column layout created"
    else
        echo "Error: Could not get window addresses"
    fi
else
    echo "Could not arrange windows - some applications did not start properly"
fi

hyprctl dispatch workspace 2

echo "Workspace 1 dwindle layout setup complete"