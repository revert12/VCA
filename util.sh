#!/bin/bash

# 오류 로그를 위한 함수
log_error() {
    echo "Error: $1"
}

sudo apt-get update

# bpytop 설치
if ! command -v bpytop &> /dev/null; then
    echo "Installing bpytop..."
    sudo snap install -y bpytop
else
    echo "bpytop is already installed."
fi

# vim 설치
if command -v vim &> /dev/null; then
        echo "Vim is already installed."
else
        if sudo apt-get install -y vim; then
            echo "Vim installed successfully."
        else
            log_error "Failed to install Vim."
        fi
fi

# Add 'set number' to .vimrc
if ! grep -q "set number" ~/.vimrc; then
    echo "set number" >> ~/.vimrc
    echo "'set number' added to ~/.vimrc."
else
    echo "'set number' is already present in ~/.vimrc."
fi

# net-tools install
if command -v ifconfig &> /dev/null; then
        echo "net-tools is already installed."
else 
    if sudo apt-get install -y net-tools; then
        echo "net-tools installed successfully."
    else
        log_error "Failed to install net-tools."
    fi
fi


