#!/bin/bash

TIME_SPAN="2 minute ago"
LOGFILE="/var/log/monitor.log"
SERVICE="test_api.timer"
URL="https://test.com/monitoring/test/api"
TIME_STAMP=$(date +"%Y-%m-%d %H:%M:%S")

log_msg_not_available(){
   echo "$TIME_STAMP - Server is not available" $1 >> "$LOGFILE"
}

log_msg_restarted(){
    echo "$TIME_STAMP - Services restarted!" $1 >> "$LOGFILE"
}

if systemctl is-active --quiet "$SERVICE"; then
    STATUS_CODE=$(curl -I -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$URL")

    if ! [ "$STATUS_CODE" -eq 200 ]; then
       log_msg_not_available
    fi
fi

LOG_EVENTS=$(journalctl -u "$SERVICE" --since "$TIME_SPAN" | grep -iE 'Started|Restarting')

if [ -n "$LOG_EVENTS" ]; then
    log_msg_restarted
fi
