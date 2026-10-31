#!/bin/bash

# Linux Server Health Monitoring
# Version 1.1

LOG_FILE="$HOME/linux-server-monitor/logs/monitor.log"
CONFIG_FILE="$HOME/linux-server-monitor/config/monitor.conf"
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Record critical incidents
log_incident() {
    local resource="$1"
    local value="$2"

    local incident_file="$HOME/linux-server-monitor/reports/incidents.log"

    {
        echo "================================"
        echo "INCIDENT DETECTED"
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Issue: $resource"
        echo "Value: $value"
        echo "Status: CRITICAL"
        echo "================================"
        echo
    } >> "$incident_file"
}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file is not readable: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Validate configuration thresholds
for value in "$WARNING_LOAD" "$CRITICAL_LOAD" \
             "$WARNING_MEMORY" "$CRITICAL_MEMORY" \
             "$WARNING_DISK" "$CRITICAL_DISK"; do
    if ! [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "ERROR: Invalid threshold value: $value"
        exit 1
    fi
done


echo "=================================="
echo "   LINUX SERVER HEALTH REPORT"
echo "=================================="

echo "Hostname: $(hostname)"
echo "Date: $(date)"
log_message "Monitoring started"
echo

# CPU Load Monitoring
CURRENT_LOAD=$(awk '{print $1}' /proc/loadavg)

echo "CPU Load Average: $CURRENT_LOAD"

if awk -v current_load="$CURRENT_LOAD" -v limit="$CRITICAL_LOAD" \
    'BEGIN {exit !(current_load >= limit)}'; then
    echo "CPU Load Status: CRITICAL"
    log_message "CPU Load: $CURRENT_LOAD | Status: CRITICAL"
    log_incident "CPU Load" "$CURRENT_LOAD"
  
elif awk -v current_load="$CURRENT_LOAD" -v limit="$WARNING_LOAD" \
    'BEGIN {exit !(current_load >= limit)}'; then
    echo "CPU Load Status: WARNING"
    log_message "CPU Load: $CURRENT_LOAD | Status: WARNING"
else
    echo "CPU Load Status: NORMAL"
    log_message "CPU Load: $CURRENT_LOAD | Status: NORMAL"
fi

echo

# Memory Monitoring

MEMORY_USAGE=$(awk '/MemTotal:/ {total=$2} /MemAvailable:/ {available=$2} END {
    printf "%.0f", ((total - available) / total) * 100
}' /proc/meminfo)

echo "Memory Usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -ge "$CRITICAL_MEMORY" ]; then
    echo "Memory Status: CRITICAL"
    log_message "Memory Usage: ${MEMORY_USAGE}% | Status: CRITICAL"
    log_incident "Memory Usage" "${MEMORY_USAGE}%"
elif [ "$MEMORY_USAGE" -ge "$WARNING_MEMORY" ]; then
    echo "Memory Status: WARNING"
    log_message "Memory Usage: ${MEMORY_USAGE}% | Status: WARNING"
else
    echo "Memory Status: NORMAL"
    log_message "Memory Usage: ${MEMORY_USAGE}% | Status: NORMAL"
fi

free -h
echo

# Disk Monitoring


DISK_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

echo "Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$CRITICAL_DISK" ]; then
    echo "Disk Status: CRITICAL"
    log_message "Disk Usage: ${DISK_USAGE}% | Status: CRITICAL"
    log_incident "Disk Usage" "${DISK_USAGE}%"
elif [ "$DISK_USAGE" -ge "$WARNING_DISK" ]; then
    echo "Disk Status: WARNING"
    log_message "Disk Usage: ${DISK_USAGE}% | Status: WARNING"
else
    echo "Disk Status: NORMAL"
    log_message "Disk Usage: ${DISK_USAGE}% | Status: NORMAL"
fi

df -h /
echo

# Process Monitoring

PROCESS_NAME="sshd"
PROCESS_ID=$(pgrep -xo "$PROCESS_NAME")

if [ -n "$PROCESS_ID" ]; then
    echo "Process Status: $PROCESS_NAME is RUNNING (PID: $PROCESS_ID)"
    log_message "Process Status: $PROCESS_NAME is RUNNING | PID: $PROCESS_ID"
else
    echo "Process Status: $PROCESS_NAME is NOT RUNNING"
    log_message "Process Status: $PROCESS_NAME is NOT RUNNING"
fi

echo

echo "Monitoring completed."
