#!/usr/bin/env bash

# Smart Window Resize Script for Hyprland
# Simulates mouse resize using keyboard by detecting closest edge
# Usage: smart-resize.sh <action> <direction> <pixels>
# Action: extend, shrink
# Direction: left, right
# Pixels: resize amount

set -euo pipefail

# Configuration
DEFAULT_RESIZE_PIXELS=80

DEBUG=false  # Enable debug output

# Timing function for performance debugging
get_timestamp() {
    date +%s%N
}

debug_time() {
    if [[ "$DEBUG" == "true" ]]; then
        local operation="$1"
        local start_time="$2"
        local end_time
        end_time=$(get_timestamp)
        local duration_ns=$((end_time - start_time))
        local duration_ms=$((duration_ns / 1000000))
        echo "⏱️  $operation: ${duration_ms}ms" >&2
    fi
}



# Parse arguments
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <action> <direction> <pixels>"
    echo "Action: extend, shrink"
    echo "Direction: left, right"
    echo "Pixels: resize amount"
    echo ""
    echo "Examples:"
    echo "  $0 extend right 50   # Expand window 50px to the right"
    echo "  $0 shrink left 30    # Shrink window 30px from the left"
    exit 1
fi

ACTION="$1"
DIRECTION="$2"
RESIZE_PIXELS="$3"

# Validate action
case "$ACTION" in
    extend|shrink)
        ;;
    *)
        echo "Error: Invalid action '$ACTION'. Use: extend, shrink"
        exit 1
        ;;
esac

# Validate direction
case "$DIRECTION" in
    left|right)
        ;;
    *)
        echo "Error: Invalid direction '$DIRECTION'. Use: left, right"
        exit 1
        ;;
esac

# Validate pixels
if ! [[ "$RESIZE_PIXELS" =~ ^[0-9]+$ ]]; then
    echo "Error: Pixels must be a positive integer"
    exit 1
fi

# Check dependencies
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: Required dependency '$1' not found"
        echo "Please install: $2"
        exit 1
    fi
}

check_dependency "hyprctl" "hyprland"
check_dependency "dotool" "dotool"




# Get active window information (simplified - just for validation)
get_active_window_info() {
    local window_info
    window_info=$(hyprctl activewindow -j 2>/dev/null)

    if [[ -z "$window_info" ]] || [[ "$window_info" == "Invalid" ]]; then
        echo "Error: No active window found"
        exit 1
    fi

    echo "$window_info"
}

# Calculate relative drag values based on action and direction
calculate_relative_drag() {
    local action="$1"
    local direction="$2"
    local pixels="$3"

    local rel_x=0
    local rel_y=0

    case "$action-$direction" in
        extend-left)
            rel_x=$(( -pixels ))  # Move left edge left (expand)
            ;;
        extend-right)
            rel_x=$(( +pixels ))  # Move right edge right (expand)
            ;;
        shrink-left)
            rel_x=$(( +pixels ))  # Move left edge right (shrink)
            ;;
        shrink-right)
            rel_x=$(( -pixels ))  # Move right edge left (shrink)
            ;;
    esac

    echo "$rel_x $rel_y"
}

# dotool automatically cleans up on exit - no manual cleanup needed

# Simulate mouse resize using dotool and movecursortocorner
simulate_mouse_resize() {
    local direction="$1"
    local rel_x="$2"
    local rel_y="$3"

    # Map direction to corner: bottom left (0), bottom right (1), top right (2), top left (3)
    local corner
    case "$direction" in
        left)  corner=3 ;;  # top left
        right) corner=1 ;;  # bottom right
    esac

    # Move cursor to corner
    if [[ "$DEBUG" == "true" ]]; then
        echo "⏱️  Starting cursor move to corner $corner" >&2
    fi
    local cursor_start
    cursor_start=$(get_timestamp)
    hyprctl dispatch movecursortocorner "$corner" > /dev/null 2>&1
    debug_time "movecursortocorner" "$cursor_start"

    # Use dotool for all input simulation
    if [[ "$DEBUG" == "true" ]]; then
        echo "⏱️  Starting dotool sequence" >&2
    fi
    local dotool_start
    dotool_start=$(get_timestamp)

    {
        if [[ "$DEBUG" == "true" ]]; then
            echo "Step 2: Pressing Super key" >&2
        fi
        echo "keydown leftmeta"

        if [[ "$DEBUG" == "true" ]]; then
            echo "Step 3: Pressing right mouse button" >&2
        fi
        echo "buttondown right"

        if [[ "$DEBUG" == "true" ]]; then
            echo "Step 4: Dragging with relative move (x: $rel_x, y: $rel_y)" >&2
        fi
        echo "mousemove $rel_x $rel_y"

        if [[ "$DEBUG" == "true" ]]; then
            echo "Step 5: Releasing right mouse button" >&2
        fi
        echo "buttonup right"

        if [[ "$DEBUG" == "true" ]]; then
            echo "Step 6: Releasing Super key" >&2
        fi
        echo "keyup leftmeta"

    } | dotool

    debug_time "dotool sequence" "$dotool_start"
}

# Main execution
main() {
    local script_start
    script_start=$(get_timestamp)

    if [[ "$DEBUG" == "true" ]]; then
        echo "DEBUG MODE: Enabled"
        echo "Script parameters: action=$ACTION, direction=$DIRECTION, pixels=$RESIZE_PIXELS"
    fi

    # Get active window info (for validation and display only)
    if [[ "$DEBUG" == "true" ]]; then
        echo "⏱️  Getting active window info" >&2
    fi
    local window_start
    window_start=$(get_timestamp)
    local window_info
    window_info=$(get_active_window_info)
    debug_time "get_active_window_info" "$window_start"

    # Calculate relative drag values
    local rel_drag
    rel_drag=$(calculate_relative_drag "$ACTION" "$DIRECTION" "$RESIZE_PIXELS")
    read -r rel_x rel_y <<< "$rel_drag"

    if [[ "$DEBUG" == "true" ]]; then
        echo "Relative drag: x=$rel_x, y=$rel_y"
    fi

    # Perform the resize simulation
    if [[ "$DEBUG" == "true" ]]; then
        echo "⏱️  Starting resize simulation" >&2
    fi
    local resize_start
    resize_start=$(get_timestamp)
    simulate_mouse_resize "$DIRECTION" "$rel_x" "$rel_y"
    debug_time "resize simulation" "$resize_start"

    debug_time "total script execution" "$script_start"
}

# Run main function
main "$@"