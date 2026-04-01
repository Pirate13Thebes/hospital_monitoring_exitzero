#!/bin/bash
# archive_log.sh - Archives heart_rate_log.txt with a timestamp
# Author: Grace
# Description: Renames the current heart_rate_log.txt file with a
#              timestamp in the format YYYYMMDD_HHMMSS to archive it


# Define the log file
LOG_FILE="heart_rate_log.txt"


# Check if the log file exists before archiving
if [ -f "$LOG_FILE" ]; then
    timestamp=$(date "+%Y%m%d_%H%M%S")           # Capture current timestamp
    mv "$LOG_FILE" "${LOG_FILE}_${timestamp}"     # Rename with timestamp
    echo "Archived successfully: ${LOG_FILE}_${timestamp}"
else
    # Log file not found
    echo "Error: $LOG_FILE not found. Is the monitor running?"
fi
