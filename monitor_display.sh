#!/bin/bash
# monitor_display.sh - Beautiful UI display for heart rate log
# Author: Chrys
# Description: Live terminal dashboard for heart rate monitoring
#              with alerts, stats, trends and device filter


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
BLINK='\033[5m'
NC='\033[0m'


LOG_FILE="heart_rate_log.txt"
BPM_LOW=50
BPM_HIGH=90


# Feature 4 - Device filter
read -p "Enter device name to monitor (or press Enter for ALL): " FILTER_DEVICE


# Function to draw header
draw_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}       🏥  HOSPITAL HEART RATE MONITOR  🏥        ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}              Team ExitZero - ALCHE               ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}


# Function to get heart rate status
get_status() {
    local bpm=$1
    if [ "$bpm" -lt "$BPM_LOW" ]; then
        echo -e "${BLUE}LOW${NC}"
    elif [ "$bpm" -le "$BPM_HIGH" ]; then
        echo -e "${GREEN}NORMAL${NC}"
    elif [ "$bpm" -le 100 ]; then
        echo -e "${YELLOW}ELEVATED${NC}"
    else
        echo -e "${RED}HIGH${NC}"
    fi
}


# Feature 2 - Alert system
check_alert() {
    local bpm=$1
    if [ "$bpm" -lt "$BPM_LOW" ]; then
        echo -e "${BLINK}${BLUE}  ⚠  ALERT: BPM TOO LOW! ($bpm bpm) — Check patient immediately!${NC}"
        printf '\a'  # Beep
    elif [ "$bpm" -gt "$BPM_HIGH" ]; then
        echo -e "${BLINK}${RED}  ⚠  ALERT: BPM TOO HIGH! ($bpm bpm) — Check patient immediately!${NC}"
        printf '\a'  # Beep
    fi
}


# Function to draw BPM bar
draw_bar() {
    local bpm=$1
    local bar_length=$((bpm / 5))
    local bar=""
    for ((i=0; i<bar_length; i++)); do
        bar="${bar}█"
    done
    if [ "$bpm" -lt "$BPM_LOW" ]; then
        echo -e "${BLUE}  ${bar}${NC} ${WHITE}$bpm bpm${NC}"
    elif [ "$bpm" -le "$BPM_HIGH" ]; then
        echo -e "${GREEN}  ${bar}${NC} ${WHITE}$bpm bpm${NC}"
    elif [ "$bpm" -le 100 ]; then
        echo -e "${YELLOW}  ${bar}${NC} ${WHITE}$bpm bpm${NC}"
    else
        echo -e "${RED}  ${bar}${NC} ${WHITE}$bpm bpm${NC}"
    fi
}


# Feature 5 - ASCII trend graph
draw_trend() {
    echo -e "${WHITE}  📈 BPM TREND (last 10 readings):${NC}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"


    local readings
    if [ -z "$FILTER_DEVICE" ]; then
        readings=$(tail -10 "$LOG_FILE" | awk '{print $4}')
    else
        readings=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -10 | awk '{print $4}')
    fi


    local graph=""
    for bpm in $readings; do
        local height=$((bpm / 20))
        if [ "$bpm" -lt "$BPM_LOW" ]; then
            graph="${graph}${BLUE}▂${NC}"
        elif [ "$bpm" -le "$BPM_HIGH" ]; then
            graph="${graph}${GREEN}▄${NC}"
        elif [ "$bpm" -le 100 ]; then
            graph="${graph}${YELLOW}▆${NC}"
        else
            graph="${graph}${RED}█${NC}"
        fi
    done
    echo -e "  $graph"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"
    echo ""
}


# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    draw_header
    echo -e "${RED}  ⚠ No log file found. Start heart_rate_monitor.sh first!${NC}"
    exit 1
fi


# Live display loop
while true; do
    draw_header


    # Feature 4 - Apply device filter
    if [ -z "$FILTER_DEVICE" ]; then
        DISPLAY_DATA=$(tail -10 "$LOG_FILE")
        LATEST=$(tail -1 "$LOG_FILE")
        ALL_DATA=$(cat "$LOG_FILE")
    else
        DISPLAY_DATA=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -10)
        LATEST=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -1)
        ALL_DATA=$(grep "$FILTER_DEVICE" "$LOG_FILE")
        echo -e "  ${MAGENTA}🔍 Filtering by device: ${BOLD}$FILTER_DEVICE${NC}"
        echo ""
    fi


    # Latest readings table
    echo -e "${WHITE}  📋 LATEST READINGS:${NC}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}  TIMESTAMP              DEVICE      BPM   STATUS${NC}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"


    echo "$DISPLAY_DATA" | while read -r t1 t2 device bpm; do
        status=$(get_status "$bpm")
        printf "  ${YELLOW}%s %s${NC}  ${CYAN}%-10s${NC}  ${WHITE}%-5s${NC}  %s\n" \
               "$t1" "$t2" "$device" "$bpm" "$status"
    done


    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"
    echo ""


    # Get latest BPM stats
    latest_bpm=$(echo "$LATEST" | awk '{print $4}')
    latest_device=$(echo "$LATEST" | awk '{print $3}')
    latest_time=$(echo "$LATEST" | awk '{print $1, $2}')


    # Feature 1 - Blinking heart animation based on BPM
    if [ "$(($(date +%s) % 2))" -eq 0 ]; then
        HEART="${RED}❤️${NC}"
    else
        HEART="${WHITE}🤍${NC}"
    fi


    # Feature 3 - Min/Max BPM tracker
    MAX_BPM=$(echo "$ALL_DATA" | awk '{print $4}' | sort -n | tail -1)
    MIN_BPM=$(echo "$ALL_DATA" | awk '{print $4}' | sort -n | head -1)


    # Display live stats
    echo -e "${WHITE}  📊 LIVE STATS:${NC}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"
    echo -e "  ${WHITE}Device   :${NC} ${CYAN}$latest_device${NC}"
    echo -e "  ${WHITE}Last BPM :${NC} ${GREEN}$latest_bpm bpm${NC}  $HEART"
    echo -e "  ${WHITE}Time     :${NC} ${YELLOW}$latest_time${NC}"
    echo -e "  ${WHITE}Status   :${NC} $(get_status $latest_bpm)"
    echo -e "  ${WHITE}Max BPM  :${NC} ${RED}$MAX_BPM bpm${NC}"
    echo -e "  ${WHITE}Min BPM  :${NC} ${BLUE}$MIN_BPM bpm${NC}"
    echo ""


    # BPM Meter
    echo -e "  ${WHITE}BPM METER:${NC}"
    draw_bar "$latest_bpm"
    echo ""


    # Feature 5 - Trend graph
    draw_trend


    # Feature 2 - Alert check
    check_alert "$latest_bpm"


    # Total readings
    total=$(echo "$ALL_DATA" | wc -l)
    echo -e "  ${WHITE}Total Readings: ${CYAN}$total${NC}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}"
    echo -e "  ${YELLOW}Refreshing every second... Press Ctrl+C to exit${NC}"


    sleep 1
done



