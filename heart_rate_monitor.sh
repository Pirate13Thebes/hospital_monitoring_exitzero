#!/bin/bash
# heart_rate_monitor.sh - Records heart rate data every second
# Author: Leslie
# Description: Prompts for a device name, logs simulated heart rate
#   data every second into heart_rate_log.txt as a background process


# Prompt user for the device name
read -p "Enter device name (e.g. Monitor_A): " device_name


# Define the log file
LOG_FILE="heart_rate_log.txt"


# Run the logging loop in the background
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")       # Capture current timestamp
    heart_rate=$((RANDOM % 61 + 40))              # Simulate heart rate between 40-100 bpm
    echo "$timestamp $device_name $heart_rate" >> "$LOG_FILE"  # Append to log
    sleep 1                                        # Wait 1 second before next reading
done &


# Display the process ID for management
echo "Heart rate monitor started. PID: $!"



