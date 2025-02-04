![Zabbix](https://img.shields.io/badge/Zabbix-7.0%2B-blue) ![License](https://img.shields.io/badge/License-GPLv3-blue.svg)

## Requirements
- **Zabbix Server** version 7.0 or higher

## Notice
This template is designed for use with the **Zabbix Agent (active)**.

## Description
This template monitors SSH authentication attempts via the Zabbix Agent, distinguishing successful (Accepted) from failed (Invalid user) logins by processing only entries with valid source IPs and logging relevant details.

## Setup

### Step 1: Clone the Repository and Install the Script
```bash
git clone https://github.com/Garfieldttt/Zabbix-SSH-by-zabbix-agent-active.git /tmp/Zabbix-SSH && install -m 755 /tmp/Zabbix-SSH/7.0/filter-auth.sh /usr/local/sbin/
```
### Step 2: Configure the Cron Job
```bash
crontab -e
```
### Add the following line to execute the script every minute:
```bash
* * * * * /usr/local/sbin/filter-auth.sh
```
Step 3: Import the Zabbix Template
Follow your standard Zabbix template import procedure to load the template into your Zabbix server.
