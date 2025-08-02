#!/bin/bash
# Dynamic zoom control script for Hyprland
# Usage: ./zoom.sh [in|out|status|reset]

# Configuration
STATE_FILE="/tmp/hypr-zoom.state"
DEFAULT_ZOOM=1.0
ZOOM_INCREMENT=1.0

# Function to read current zoom level from state file
read_state() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_ZOOM"
  else
    echo "$DEFAULT_ZOOM"
  fi
}

# Function to write current zoom level to state file
write_state() {
  echo "$1" > "$STATE_FILE"
}

# Function to apply zoom level
apply_zoom() {
  local zoom_level="$1"
  hyprctl keyword cursor:zoom_factor "$zoom_level"
}

# Function to zoom in
zoom_in() {
  local current_zoom=$(read_state)
  local new_zoom=$(echo "$current_zoom + $ZOOM_INCREMENT" | bc -l)

  write_state "$new_zoom"
  apply_zoom "$new_zoom"
}

# Function to zoom out
zoom_out() {
  local current_zoom=$(read_state)
  local new_zoom=$(echo "$current_zoom - $ZOOM_INCREMENT" | bc -l)

  # Don't go below 1.0
  if (( $(echo "$new_zoom < 1.0" | bc -l) )); then
    new_zoom="1.0"
  fi

  write_state "$new_zoom"
  apply_zoom "$new_zoom"
}

# Function to reset zoom
reset_zoom() {
  write_state "$DEFAULT_ZOOM"
  apply_zoom "$DEFAULT_ZOOM"
}

# Function to show current status
show_status() {
  local current_zoom=$(read_state)
  echo "Current zoom level: $current_zoom"
}

# Main logic
case "${1:-}" in
"in")
  zoom_in
  ;;
"out")
  zoom_out
  ;;
"reset")
  reset_zoom
  ;;
"status")
  show_status
  ;;
*)
  echo "Usage: $0 [in|out|reset|status]"
  echo "  in       - Zoom in (increase zoom level)"
  echo "  out      - Zoom out (decrease zoom level, minimum 1.0)"
  echo "  reset    - Reset zoom to 1.0"
  echo "  status   - Show current zoom level"
  echo ""
  echo "Current status:"
  show_status
  exit 1
  ;;
esac