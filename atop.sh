#!/bin/bash

# atop 설치
if ! command -v atop &> /dev/null; then
    echo "Installing atop..."
    sudo apt-get update
    sudo apt-get install -y atop
else
    echo "atop is already installed."
fi

# cron 작업 추가: 30일 이상 된 로그 삭제
CRON_JOB="0 2 * * * find /var/log/atop/ -type f -name 'atop_*' -mtime +30 -exec rm {} \\;"
(crontab -l; echo "$CRON_JOB") | crontab -

echo "Cron job added to delete logs older than 30 days."
