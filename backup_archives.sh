#!/bin/bash
# backup_archives.sh - Moves archived logs and backs up via SSH/SCP
# Author: Chrys Elisee Gnagne
# Description: Moves all timestamped log files into archived_logs_exitzero
#              directory and securely backs them up to a remote server

# Define the archive directory name
ARCHIVE_DIR="archived_logs_exitzero"

# Create the archive directory if it doesn't already exist
mkdir -p "$ARCHIVE_DIR"

# Move all timestamped archived log files into the archive directory
mv heart_rate_log.txt_* "$ARCHIVE_DIR/" 2>/dev/null
echo "Files moved to $ARCHIVE_DIR/"

# Prompt for remote server connection details
read -p "Enter remote host: " remote_host
read -p "Enter remote username: " remote_user

# Securely copy the archive directory to the remote server using SCP
scp -r "$ARCHIVE_DIR" "${remote_user}@${remote_host}:/home/"
echo "Backup to $remote_host complete."
