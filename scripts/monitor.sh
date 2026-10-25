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
    echo "CPU Load Status: CRITICAL"
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

MEMORY_USAGE=$(awk '/MemTotal:/ {total=$2} /MemAvailable:/ {available=$2} END {
    printf "%.0f", ((total - available) / total) * 100
}' /proc/meminfo)

echo "Memory Usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -ge "$CRITICAL_MEMORY" ]; then
    echo "Memory Status: CRITICAL"
    log_message "Memory Usage: ${MEMORY_USAGE}% | Status: CRITICAL"
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
WARNING_DISK=80
CRITICAL_DISK=90

DISK_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

echo "Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$CRITICAL_DISK" ]; then
    echo "Disk Status: CRITICAL"
    log_message "Disk Usage: ${DISK_USAGE}% | Status: CRITICAL"
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
