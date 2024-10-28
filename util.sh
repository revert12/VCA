#!/bin/bash

# 오류 로그를 위한 함수
log_error() {
    echo "Error: $1"
}

sudo apt-get update

# bpytop 설치
if  command -v bpytop &> /dev/null; then
    echo "bpytop is already installed."

else
    echo "Installing bpytop..."
    sudo snap install -y bpytop
fi

# vim 설치
if command -v vim &> /dev/null; then
    echo "Vim is already installed."
    
        if grep -q "set number" ~/.vimrc; then
            echo "'set number' is already present in ~/.vimrc."
        else
            echo "set number" >> ~/.vimrc
            echo "'set number' added to ~/.vimrc."
        fi       
else
        if sudo apt-get install -y vim; then
            echo "Vim installed successfully."
            echo "set number" >> ~/.vimrc
            echo "'set number' added to ~/.vimrc."
        else
            log_error "Failed to install Vim."
        fi       
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

# vlc install
if command -v vlc &> /dev/null; then
        echo "vlc is already installed."
else 
        if sudo apt-get install -y vlc; then
            echo "vlc installed successfully."
        else
            log_error "Failed to install vlc."
        fi 
fi

# anydesk install
if command -v anydesk &> /dev/null; then
        echo "anydesk is already installed."
else 
        if sudo apt-get install -y anydesk; then
            echo "anydesk installed successfully."
        else
            log_error "Failed to install anydesk."
        fi 
fi


