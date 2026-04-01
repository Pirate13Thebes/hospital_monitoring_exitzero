#!/bin/bash
# monitor_display.sh - Beautiful UI display for heart rate log
# Author: Chrys
# Description: Live terminal dashboard for heart rate monitoring

export TZ='Indian/Mauritius'

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
CLEAR_LINE='\033[K'   # Erase to end of line — prevents bleed from previous frame

LOG_FILE="heart_rate_log.txt"
BPM_LOW=50
BPM_HIGH=90

# Clean exit — restores terminal properly
cleanup() {
    tput rmcup
    tput cnorm
    echo -e "${GREEN}Monitor stopped. Goodbye!${NC}"
    exit 0
}
trap cleanup INT TERM

# Device filter
read -p "Enter device name to monitor (or press Enter for ALL): " FILTER_DEVICE

# Enter alternate screen and hide cursor
tput smcup
tput civis

# Returns plain status text (used for padding calculation)
get_status_plain() {
    local bpm=$1
    if ! [[ "$bpm" =~ ^[0-9]+$ ]]; then echo "N/A"; return; fi
    if   [ "$bpm" -lt "$BPM_LOW" ]; then echo "LOW"
    elif [ "$bpm" -le "$BPM_HIGH" ]; then echo "NORMAL"
    elif [ "$bpm" -le 100 ];         then echo "ELEVATED"
    else                                  echo "HIGH"
    fi
}

# Returns colored status padded to fixed width (avoids bleed into next column)
get_status_padded() {
    local bpm=$1
    local plain
    plain=$(get_status_plain "$bpm")
    local pad=$(( 9 - ${#plain} ))
    local spaces
    spaces=$(printf '%*s' "$pad" '')

    case "$plain" in
        LOW)      echo -e "${BLUE}${plain}${NC}${spaces}" ;;
        NORMAL)   echo -e "${GREEN}${plain}${NC}${spaces}" ;;
        ELEVATED) echo -e "${YELLOW}${plain}${NC}${spaces}" ;;
        HIGH)     echo -e "${RED}${plain}${NC}${spaces}" ;;
        *)        echo -e "${WHITE}${plain}${NC}${spaces}" ;;
    esac
}

# Alert check
check_alert() {
    local bpm=$1
    if ! [[ "$bpm" =~ ^[0-9]+$ ]]; then
        echo -e "  ${WHITE}No data yet.${NC}${CLEAR_LINE}"
        return
    fi
    if [ "$bpm" -lt "$BPM_LOW" ]; then
        echo -e "${BLINK}${BLUE}  ⚠  ALERT: BPM TOO LOW! ($bpm bpm) — Check patient immediately!${NC}${CLEAR_LINE}"
        printf '\a'
    elif [ "$bpm" -gt "$BPM_HIGH" ]; then
        echo -e "${BLINK}${RED}  ⚠  ALERT: BPM TOO HIGH! ($bpm bpm) — Check patient immediately!${NC}${CLEAR_LINE}"
        printf '\a'
    else
        echo -e "  ${GREEN}✔  All vitals within normal range.${NC}${CLEAR_LINE}"
    fi
}

# BPM bar
draw_bar() {
    local bpm=$1
    if ! [[ "$bpm" =~ ^[0-9]+$ ]]; then
        echo -e "  ${WHITE}No data available${NC}${CLEAR_LINE}"
        return
    fi
    local bar_length=$(( bpm / 5 ))
    local bar
    bar=$(printf '█%.0s' $(seq 1 $bar_length))
    if   [ "$bpm" -lt "$BPM_LOW" ]; then echo -e "${BLUE}  ${bar}${NC} ${WHITE}${bpm} bpm${NC}${CLEAR_LINE}"
    elif [ "$bpm" -le "$BPM_HIGH" ]; then echo -e "${GREEN}  ${bar}${NC} ${WHITE}${bpm} bpm${NC}${CLEAR_LINE}"
    elif [ "$bpm" -le 100 ];          then echo -e "${YELLOW}  ${bar}${NC} ${WHITE}${bpm} bpm${NC}${CLEAR_LINE}"
    else                                   echo -e "${RED}  ${bar}${NC} ${WHITE}${bpm} bpm${NC}${CLEAR_LINE}"
    fi
}

# Trend graph
draw_trend() {
    echo -e "${WHITE}  📈 BPM TREND (last 10 readings):${NC}${CLEAR_LINE}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}"
    local readings
    if [ -z "$FILTER_DEVICE" ]; then
        readings=$(tail -10 "$LOG_FILE" | awk '{print $NF}')
    else
        readings=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -10 | awk '{print $NF}')
    fi
    local graph=""
    for bpm in $readings; do
        if ! [[ "$bpm" =~ ^[0-9]+$ ]]; then continue; fi
        if   [ "$bpm" -lt "$BPM_LOW" ]; then graph="${graph}${BLUE}▂ ${NC}"
        elif [ "$bpm" -le "$BPM_HIGH" ]; then graph="${graph}${GREEN}▄ ${NC}"
        elif [ "$bpm" -le 100 ];          then graph="${graph}${YELLOW}▆ ${NC}"
        else                                   graph="${graph}${RED}█ ${NC}"
        fi
    done
    echo -e "  $graph${CLEAR_LINE}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
}

# Check log exists
if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}  ⚠ No log file found. Start heart_rate_monitor.sh first!${NC}"
    sleep 3
    cleanup
fi

# ── Main live loop ──────────────────────────────────────────────────────────
while true; do

    # Build entire frame into a variable, then print once — prevents mid-draw artifacts
    FRAME=""

    # Header
    FRAME+="${CYAN}╔══════════════════════════════════════════════════╗${NC}\n"
    FRAME+="${CYAN}║${WHITE}       🏥  HOSPITAL HEART RATE MONITOR  🏥        ${CYAN}║${NC}\n"
    FRAME+="${CYAN}║${YELLOW}              Team ExitZero - ALCHE               ${CYAN}║${NC}\n"
    FRAME+="${CYAN}╚══════════════════════════════════════════════════╝${NC}\n"
    FRAME+="\n"

    # Gather data
    if [ -z "$FILTER_DEVICE" ]; then
        DISPLAY_DATA=$(tail -10 "$LOG_FILE")
        LATEST=$(tail -1 "$LOG_FILE")
        ALL_DATA=$(cat "$LOG_FILE")
    else
        DISPLAY_DATA=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -10)
        LATEST=$(grep "$FILTER_DEVICE" "$LOG_FILE" | tail -1)
        ALL_DATA=$(grep "$FILTER_DEVICE" "$LOG_FILE")
        FRAME+="  ${MAGENTA}🔍 Filtering by device: ${BOLD}${FILTER_DEVICE}${NC}${CLEAR_LINE}\n"
        FRAME+="\n"
    fi

    # Table
    FRAME+="${WHITE}  📋 LATEST READINGS:${NC}${CLEAR_LINE}\n"
    FRAME+="${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}\n"
    FRAME+="$(printf "  ${WHITE}%-22s %-14s %-7s %-10s${NC}" "TIMESTAMP" "DEVICE" "BPM" "STATUS")${CLEAR_LINE}\n"
    FRAME+="${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}\n"

    if [ -z "$DISPLAY_DATA" ]; then
        FRAME+="  ${YELLOW}  No data found for this device.${NC}${CLEAR_LINE}\n"
    else
        while read -r line; do
            f1=$(echo "$line" | awk '{print $1}')
            f2=$(echo "$line" | awk '{print $2}')
            bpm=$(echo "$line" | awk '{print $NF}')
            device=$(echo "$line" | awk '{for(i=3;i<NF;i++) printf $i" "; print ""}' | sed 's/ $//')
            status_padded=$(get_status_padded "$bpm")
            FRAME+="$(printf "  ${YELLOW}%-11s %-8s${NC}  ${CYAN}%-14s${NC}  ${WHITE}%-5s${NC}  " \
                "$f1" "$f2" "$device" "$bpm")${status_padded}${CLEAR_LINE}\n"
        done <<< "$DISPLAY_DATA"
    fi

    FRAME+="${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}\n"
    FRAME+="\n"

    # Parse latest
    latest_bpm=$(echo "$LATEST" | awk '{print $NF}')
    latest_device=$(echo "$LATEST" | awk '{for(i=3;i<NF;i++) printf $i" "; print ""}' | sed 's/ $//')
    latest_time=$(echo "$LATEST" | awk '{print $1, $2}')
    MAX_BPM=$(echo "$ALL_DATA" | awk '{print $NF}' | grep -E '^[0-9]+$' | sort -n | tail -1)
    MIN_BPM=$(echo "$ALL_DATA" | awk '{print $NF}' | grep -E '^[0-9]+$' | sort -n | head -1)

    # Heart animation
    if [ "$(( $(date +%s) % 2 ))" -eq 0 ]; then HEART="${RED}❤️ ${NC}"; else HEART="${WHITE}🤍${NC}"; fi

    # Live stats
    FRAME+="${WHITE}  📊 LIVE STATS:${NC}${CLEAR_LINE}\n"
    FRAME+="${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Device   :${NC} ${CYAN}${latest_device:-N/A}${NC}${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Last BPM :${NC} ${GREEN}${latest_bpm:-N/A} bpm${NC}  ${HEART}${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Time     :${NC} ${YELLOW}${latest_time:-N/A}${NC}${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Status   :${NC} $(get_status_padded "${latest_bpm:-0}")${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Max BPM  :${NC} ${RED}${MAX_BPM:-N/A} bpm${NC}${CLEAR_LINE}\n"
    FRAME+="  ${WHITE}Min BPM  :${NC} ${BLUE}${MIN_BPM:-N/A} bpm${NC}${CLEAR_LINE}\n"
    FRAME+="\n"

    # Print entire frame at once — move to top, erase screen, then render
    printf '\033[H\033[J'
    printf "%b" "$FRAME"

    # BPM Meter (printed live after frame — safe since we're past the overlap zone)
    echo -e "  ${WHITE}BPM METER:${NC}${CLEAR_LINE}"
    draw_bar "${latest_bpm:-0}"
    echo -e "${CLEAR_LINE}"

    draw_trend

    check_alert "${latest_bpm:-0}"

    total=$(echo "$ALL_DATA" | grep -c .)
    echo -e "  ${WHITE}Total Readings: ${CYAN}${total}${NC}${CLEAR_LINE}"
    echo -e "${CYAN}  ──────────────────────────────────────────────────${NC}${CLEAR_LINE}"
    echo -e "  ${YELLOW}Refreshing every second... Press Ctrl+C to exit${NC}${CLEAR_LINE}"

    sleep 1
done
