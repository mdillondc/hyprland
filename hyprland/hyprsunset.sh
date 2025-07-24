#!/bin/bash
# Temperature cycling control for hyprsunset
# Usage: ./hyprsunset-cycle.sh [cycle|status|off]

# Configuration
TEMPERATURES=("identity" "temperature 2000" "temperature 3500")
TEMPERATURE_NAMES=("Off" "2000K" "3500K")
STATE_FILE="/tmp/hyprsunset.state"

# Function to read current temperature index from state file
read_state() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Function to write current temperature index to state file
write_state() {
  echo "$1" > "$STATE_FILE"
}

# Function to send desktop notification and update waybar
send_notification() {
  local temp_name="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -t 1000 -h string:x-canonical-private-synchronous:nightlight "Night Light" "$temp_name"
  fi
  # Signal waybar to update hyprsunset module
  pkill -SIGRTMIN+10 waybar
}

# Function to check if hyprsunset service is running
is_running() {
  pgrep -x "hyprsunset" >/dev/null 2>&1
}

# Function to ensure hyprsunset service is running
ensure_service() {
  if ! is_running; then
    hyprsunset &
    sleep 1
  fi
}

# Function to apply temperature setting
apply_temperature() {
  local temp_command="$1"
  ensure_service
  hyprctl hyprsunset "$temp_command"
}

# Function to show status
show_status() {
  if is_running; then
    echo "hyprsunset service is running"
    if [[ -f "$STATE_FILE" ]]; then
      local current_index=$(read_state)
      echo "Current temperature setting: ${TEMPERATURE_NAMES[$current_index]}"
    fi
    return 0
  else
    echo "hyprsunset service is not running"
    return 1
  fi
}

# Function to cycle through temperatures
cycle_temperature() {
  local current_index=$(read_state)
  local next_index=$(( (current_index + 1) % ${#TEMPERATURES[@]} ))
  local next_temp_command="${TEMPERATURES[$next_index]}"
  local temp_name="${TEMPERATURE_NAMES[$next_index]}"

  write_state "$next_index"
  apply_temperature "$next_temp_command"
  send_notification "$temp_name"
}

# Main logic
case "${1:-}" in
"cycle")
  cycle_temperature
  ;;
"off")
  ensure_service
  hyprctl hyprsunset identity
  write_state "0"
  send_notification "Off"
  ;;
"status")
  show_status
  ;;
*)
  echo "Usage: $0 [cycle|off|status]"
  echo "  cycle     - Cycle through temperature settings"
  echo "  off       - Turn off blue light filter"
  echo "  status    - Show current status and temperature setting"
  echo ""
  echo "Available temperatures: ${TEMPERATURE_NAMES[*]}"
  echo ""
  echo "Current status:"
  show_status
  exit 1
  ;;
esac