#!/bin/bash

# sysstat,smartmontools 설치
if ! command -v iostat &> /dev/null; then
    echo "Installing sysstat..."
    sudo apt-get update
    sudo apt-get install -y sysstat
    sudo apt-get install -y smartmontools
else
    echo "sysstat,smartmontools is already installed."
fi




# sysstat 서비스 시작
if ! systemctl is-active --quiet sysstat; then
   sudo systemctl start sysstat
   sudo systemctl enable sysstat
   echo "sysstat 서비스가 시작되었습니다."
else
   echo "sysstat 서비스가 이미 실행 중입니다."
fi

## sysstat 설정 파일 경로
# SYSSTAT_CONF="/etc/default/sysstat"
## sysstat 로그 작성을 Enable로 설정
#if grep -q '^ENABLED="false"' "$SYSSTAT_CONF"; then
#    sudo sed -i 's/^ENABLED="false"/ENABLED="true"/' "$SYSSTAT_CONF"
#    echo "sysstat 로그 작성이 활성화되었습니다."
#else
#    echo "sysstat 로그 작성이 이미 활성화되어 있습니다."
#fi


## 크론탭에 추가할 삭제 명령어
# CRON_JOB="0 0 * * * find /var/log/sysstat -type f -name 'sa*' -mtime +30 -exec rm -f {} \;"
# 현재 크론탭에 이미 등록된 작업 확인
#if ! crontab -l | grep -qF "$CRON_JOB"; then
#    (crontab -l; echo "$CRON_JOB") | crontab -
#   echo "크론탭에 로그 삭제 작업이 추가되었습니다."
#else
#    echo "크론탭에 이미 동일한 작업이 존재합니다."
#fi
