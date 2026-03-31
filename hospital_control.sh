#!/bin/bash
# hospital_control.sh - Master controller for hospital monitoring system
# Author: Chrys
# Description: A menu-driven script that ties all hospital monitoring
#              scripts together into one clean interface

# Loop keeps the menu running until user selects Exit
while true; do

    # Display the main menu
    echo "=============================="
    echo "  HOSPITAL MONITORING SYSTEM  "
    echo "=============================="
    echo "1. Start Heart Rate Monitor"
    echo "2. Archive Current Log"
    echo "3. Backup Archives to Remote Server"
    echo "4. View Live Log"
    echo "5. Exit"
    echo "=============================="

    # Prompt user to select an option
    read -p "Select an option: " option

    # Execute the corresponding script based on user input
    case $option in
        1) ./heart_rate_monitor.sh ;;        # Starts heart rate monitor in background
        2) ./archive_log.sh ;;               # Archives the current log with timestamp
        3) ./backup_archives.sh ;;           # Backs up archives to remote server via SSH
        4) tail -f heart_rate_log.txt ;;     # Streams live log output
        5) echo "Exiting..."; exit 0 ;;      # Exits the program cleanly with code 0
        *) echo "Invalid option. Try again." ;; # Handles invalid input
    esac

done
