# 🏥 Hospital Monitoring Scripts
African Leadership College of Higher Education · BSE Year 1 · Trimester 2 · Group ExitZero
A collaborative Bash scripting project that simulates a hospital heart-rate monitoring pipeline, including live patient monitoring, log archival, dashboard visualization, backup automation, and centralized process control.

# 📚Table of Contents
- Team 
- Repository Structure
- Scripts
- Git Workflow
- Member Commentaries 

# 👥 Team
Member
Role
Task
Chrys
Group Leader
backup_archives.sh (bonus) + hospital_control.sh + monitor_display.sh + repo management
Leslie
Script Author
heart_rate_monitor.sh
Grace
Script Author
archive_log.sh
Jacinta
Tester
Run and verify heart_rate_monitor.sh with tail -f
Fanuel
Final QA
End-to-end test + README.md + final push




# 📁 Repository Structure
hospital_monitoring_group1/
+-- heart_rate_monitor.sh
+-- archive_log.sh
+-- backup_archives.sh
+-- hospital_control.sh
+-- monitor_display.sh
+-- heart_rate_log.txt
+-- README.md

# ⚙️ Scripts
heart_rate_monitor.sh
Logs simulated heart rate data every second into heart_rate_log.txt. Runs in the background and displays its PID.
chmod +x heart_rate_monitor.sh
./heart_rate_monitor.sh
tail -f heart_rate_log.txt


# Sample log:
2025-01-03 14:35:02 Monitor_A 61
2025-01-03 14:35:03 Monitor_A 74
2025-01-03 14:35:04 Monitor_A 48


Watch live: tail -f heart_rate_log.txt  |  Stop: kill <PID>

# archive_log.sh
Renames heart_rate_log.txt with a timestamp, archiving it for storage.
chmod +x archive_log.sh
./archive_log.sh


Result: heart_rate_log.txt becomes heart_rate_log.txt_20250103_143510

# monitor_display.sh
Live terminal dashboard that reads from heart_rate_log.txt and displays heart rate data in real time with color-coded status, BPM meter, trend graph, and alerts. Supports device filtering. Written by Chrys.
🎨 Color-coded BPM status
📊 Live BPM meter
📈 Trend graph
🚨 High/low heart-rate alerts
🖥️ Clean terminal UI
🔍 Device filtering support
chmod +x monitor_display.sh
./monitor_display.sh
Requires heart_rate_monitor.sh to be running first. Press Ctrl+C to exit cleanly.

# hospital_control.sh
Master controller with a menu to run any part of the pipeline without remembering individual script names.
chmod +x hospital_control.sh
./hospital_control.sh

# backup_archives.sh
Moves all archived log files into archived_logs_group1/ and backs them up to a remote server via SCP. Update REMOTE_HOST and REMOTE_USER before running.
chmod +x backup_archives.sh
./backup_archives.sh

🔀 Git Workflow
# Clone the repo
git clone https://github.com/Pirate13Thebes/hospital_monitoring_exitzero.git
cd hospital_monitoring_exitzero


# Before starting any work, always pull first
git pull origin main


# Stage, commit, and push your file
git add <your_file>
git commit -m "YourName: short description"
git push origin main


# 📝 Commit messages from this repo:
Fanuel:  Final QA passed, README added
Grace:   Add archive_log.sh -- timestamped log archival script
Jacinta: Tested heart_rate_monitor.sh - live logging confirmed with tail -f
Leslie:  Add heart_rate_monitor.sh -- background logging script
Chrys:   Added hospital_control.sh, backup_archives.sh and monitor_display.sh
Chrys:   Initial commit, repo setup

# Member Commentaries
Leslie: heart_rate_monitor.sh
I wrapped the while loop inside ( ... ) & so it runs as a background process without locking the terminal. The & tells Linux to start it and return control immediately. $! is a special variable that holds the PID of the last background job, so I capture it right after launching and print it to the user. Without the PID there would be no way to stop the monitor later.
For the heart rate I used $(( RANDOM % 60 + 40 )) to keep values in a realistic 40–99 bpm range. I used >> instead of > so every new line is appended to the log and nothing ever gets overwritten.

# Grace: archive_log.sh
The key decision was using mv instead of cp. mv renames the file in place without duplicating it, which is what archiving actually means: the live log is retired with a timestamped name so a fresh one can start next time. cp would leave the old log still active, defeating the purpose.
The format +%Y%m%d_%H%M%S puts the year first so archived files sort chronologically out of the box. The [ ! -f "$LOG_FILE" ] guard at the top checks the file exists before trying to rename it, so the script fails with a clear message instead of a confusing error.

# Chrys: hospital_control.sh, backup_archives.sh and monitor_display.sh
hospital_control.sh exists because running three scripts in the right order is easy to get wrong. A menu-driven controller makes the pipeline accessible without needing to remember filenames or sequence. I used a case statement because it maps each option to one action cleanly, much more readable than a chain of if/elif blocks. The pre-flight check at the top uses -x to confirm each script both exists and is executable before anything runs.
For backup_archives.sh, the for loop with heart_rate_log.txt_* picks up every archived file regardless of its timestamp so no names need to be hard-coded. I chose scp -r because it comes with OpenSSH which is already on every sandbox, no extra setup needed. The -r flag copies the whole directory in one command over an encrypted channel. $? checks the exit code after scp so the script always reports whether the backup actually succeeded.
monitor_display.sh is a live terminal dashboard that reads from heart_rate_log.txt every second and displays a color-coded UI with BPM status, min/max tracking, trend graph, and patient alerts. I built the entire frame into a variable before printing to avoid screen tearing. The tput smcup/rmcup pair opens an alternate screen buffer so pressing Ctrl+C restores the original terminal cleanly. Timezone is set to Mauritius (Indian/Mauritius) so all timestamps reflect local time.

# Jacinta: testing heart_rate_monitor.sh
I used tail -f instead of opening the file in a text editor because a text editor only gives a snapshot. You would have to close and reopen it every time to see new entries. tail -f stays open and streams each new line the moment it is written. Pressing Ctrl+C only exits tail, it does not stop the background monitor.
kill <PID> sends SIGTERM to that specific process, asking it to stop cleanly. Because the PID was printed when the script started, we always know exactly which process to target.

# Fanuel: README and final QA
Testing each script alone is not the same as testing the pipeline. The full end-to-end run was the only way to confirm the output of one script feeds correctly into the next. The most important check was verifying the archived filename matches heart_rate_log.txt_YYYYMMDD_HHMMSS exactly, not just that the file was renamed. Confirming heart_rate_log.txt no longer exists after archiving proves mv renamed the file rather than leaving a copy behind.
I wrote this README as part of the final QA role because documentation is only reliable after everything has been tested. Each commentary is written from the author's own perspective so the grader can see that every member understands the reasoning behind their work, not just the commands.
 
# ✅ Final Notes
This project demonstrates:
🐧 Bash scripting fundamentals
🔁 Process management
📂 File archival automation
🔐 Secure remote backups
📊 Real-time terminal dashboards
🤝 Collaborative Git workflow
🧪 QA and documentation discipline
