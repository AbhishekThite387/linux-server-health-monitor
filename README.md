# Linux Server Health & Incident Monitoring System

A Bash-based Linux server monitoring tool that monitors system resources, detects potential issues, records incidents, and manages logs automatically.

## Overview

This project monitors Linux server health using Bash scripting and standard Linux utilities. It tracks CPU load, memory usage, disk usage, and SSH service status. It also supports configurable thresholds, incident reporting, scheduled monitoring, and automatic log rotation.

## Features

- CPU load monitoring
- Memory usage monitoring
- Disk usage monitoring
- SSH service health checks
- Configurable warning and critical thresholds
- Centralized configuration using a `.conf` file
- Timestamped monitoring logs
- Critical incident reporting
- Log-writing error handling
- Automated monitoring using Cron
- Log rotation and compression using Logrotate
- Configurable log retention

## Technologies Used

- Linux (Ubuntu)
- Bash Scripting
- Git and GitHub
- Cron
- Logrotate
- Linux system utilities

## Project Structure

```text
linux-server-monitor/
├── config/
│   ├── monitor.conf
│   └── logrotate/
│       └── linux-server-monitor
├── logs/
│   └── .gitkeep
├── reports/
│   └── .gitkeep
├── scripts/
│   └── monitor.sh
├── tests/
├── README.md
└── .gitignore
```

## Configuration

Monitoring thresholds are defined in:

`config/monitor.conf`

Example:

```bash
WARNING_LOAD=2.0
CRITICAL_LOAD=4.0
WARNING_MEMORY=80
CRITICAL_MEMORY=90
WARNING_DISK=80
CRITICAL_DISK=90
```

You can modify these values according to your server requirements.

## Installation and Execution

Clone the repository:

```bash
git clone https://github.com/AbhishekThite387/linux-server-health-monitor.git
cd linux-server-health-monitor
```

Run the monitoring script:

```bash
bash scripts/monitor.sh
```

## Scheduled Monitoring

The project uses Cron to execute the monitoring script every five minutes.

Example Cron entry:

```cron
*/5 * * * * /bin/bash /home/ubuntu/linux-server-monitor/scripts/monitor.sh
```

## Log Management

Monitoring logs are stored in:

`logs/monitor.log`

Logrotate manages log size, backups, compression, and retention.

Configuration file:

`config/logrotate/linux-server-monitor`

Key settings:

- Daily log rotation
- Retention of 7 rotated logs
- Compression of older logs
- Delayed compression
- Copy and truncate strategy

The Ubuntu system `logrotate.timer` handles automatic execution.

## Incident Reporting

Critical incidents are recorded in:

`reports/incidents.log`

Each incident includes a timestamp, affected resource, measured value, and critical status.

## Error Handling

The script checks configuration file availability and readability, validates threshold values, and reports failures when it cannot write to its log file.

## Project Status

Core monitoring, incident reporting, scheduled execution, error handling, and log rotation have been implemented and tested.

Further improvements and documentation are ongoing.

## Author

**Abhishek Thite**

GitHub: [AbhishekThite387](https://github.com/AbhishekThite387)


