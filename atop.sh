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

# 현재 크론탭에 동일한 작업이 존재하는지 확인
if ! crontab -l | grep -Fxq "$CRON_JOB"; then
    # 작업이 존재하지 않으면 추가
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "Cron job added."
else
    echo "Cron job already exists."
fi

echo "Cron job added to delete logs older than 30 days."
