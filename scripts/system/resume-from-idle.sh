#!/bin/bash

# This script is designed to robustly handle resuming from an idle state where
# the display has been turned off (DPMS off) and hyprlock may have crashed.
# It ensures displays are on, cleans up old processes, and launches a fresh lock screen.

# Exit immediately if a command exits with a non-zero status.
set -e

# Step 1: Turn the displays back on.
hyprctl dispatch dpms on

# Check if hostname contains "desktop"
if [[ "$HOSTNAME" == *"desktop"* ]]; then
    # Step 2: Add a short delay to prevent race conditions.
    # This gives the compositor and display hardware time to wake up fully
    # before we attempt to draw a new window on it.
    sleep 2
    
    # Step 3: Clean up any lingering or crashed hyprlock instances.
    # Using `killall` to be sure. The `|| true` prevents the script from
    # exiting with an error if no hyprlock process is found to kill.
    killall -q hyprlock || true
    
    # Step 4: Launch a new instance of hyprlock.
    # We run it in the background so this script can exit successfully.
    hyprlock &
fi