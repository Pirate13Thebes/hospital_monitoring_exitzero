#!/bin/bash
# hospital_control.sh - Master controller for hospital monitoring system
# Author: Chrys

while true; do
    echo "=============================="
    echo "  HOSPITAL MONITORING SYSTEM  "
    echo "=============================="
    echo "1. Start Heart Rate Monitor"
    echo "2. Archive Current Log"
    echo "3. Backup Archives to Remote Server"
    echo "4. View Live Log"
    echo "5. Exit"
    echo "=============================="
    read -p "Select an option: " option

    case $option in
        1) ./heart_rate_monitor.sh ;;
        2) ./archive_log.sh ;;
        3) ./backup_archives.sh ;;
        4) tail -f heart_rate_log.txt ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
donie
