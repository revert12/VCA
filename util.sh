#!/bin/bash

# 오류 로그를 위한 함수
log_error() {
    echo "Error: $1"
}

# 패키지 목록 업데이트
if ! sudo apt-get update; then
    log_error "Failed to update package list."
fi

# 설치할 프로그램 배열
programs=("vim" "bpytop" "net-tools" "vlc" "anydesk")

# 각 프로그램 설치 여부 확인 및 설치
for program in "${programs[@]}"; do
    if command -v "$program" &> /dev/null; then
        echo "$program is already installed."
    
    elif [ "$program" == "bpytop" ]; then
        if command -v bpytop &> /dev/null; then
            echo "$program is already installed."
        else
            echo "$program is not installed. Installing $program..."
            if ! sudo snap install bpytop; then
                log_error "Failed to install $program."
            fi
        fi

    elif [ "$program" == "net-tools" ]; then
        if command -v ifconfig &> /dev/null; then
            echo "$program is already installed."
        else
            echo "$program is not installed. Installing $program..."
            if ! sudo apt-get install -y "$program"; then
                log_error "Failed to install $program."
            fi
        fi

    else
        echo "$program is not installed. Installing $program..."
        if ! sudo apt-get install -y "$program"; then
            log_error "Failed to install $program."
        fi
    fi
done

# vim 설정 추가
vim_set=("set tabstop=4" "set shiftwidth=4" "set expandtab" "set number")      


# .vimrc 설정 추가
for setting in "${vim_set[@]}"; do
    if grep -q "$setting" ~/.vimrc; then
        echo "'$setting' is already present in ~/.vimrc."
    else
        echo "$setting" >> ~/.vimrc
        echo "'$setting' added to ~/.vimrc."
    fi
done
