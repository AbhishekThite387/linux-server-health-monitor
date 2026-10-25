#!/bin/bash

# Linux Server Health Monitoring
# Version 1.1

LOG_FILE="$HOME/linux-server-monitor/logs/monitor.log"
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

WARNING_LOAD=2.0
CRITICAL_LOAD=4.0

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
    log_message "CPU Load: $CURRENT_LOAD | Status: CRITICAL"
  
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
WARNING_MEMORY=80
CRITICAL_MEMORY=90

MEMORY_USAGE=$(free | awk '/Mem:/ {
    printf "%.0f", ($3 / $2) * 100
}')

echo "Memory Usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -ge "$CRITICAL_MEMORY" ]; then
    echo "Memory Status: CRITICAL"
    log_message "Memory Status: CRITICAL"
elif [ "$MEMORY_USAGE" -ge "$WARNING_MEMORY" ]; then
    echo "Memory Status: WARNING"
    log_message "Memory Status: WARNING"
else
    echo "Memory Status: NORMAL"
    log_message "Memory Status: NORMAL"
fi

free -h
echo

# Disk Monitoring
WARNING_DISK=80
CRITICAL_DISK=90

DISK_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

echo "Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$CRITICAL_DISK" ]; then
    echo "Disk Status: CRITICAL"
    log_message "Disk Status: CRITICAL"
elif [ "$DISK_USAGE" -ge "$WARNING_DISK" ]; then
    echo "Disk Status: WARNING"
    log_message "Disk Status: WARNING"
else
    echo "Disk Status: NORMAL"
    log_message "Disk Status: NORMAL"
fi

df -h /
echo

echo "Monitoring completed."
