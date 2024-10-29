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

# 탭의 크기를 4로 설정, 자동 들여쓰기의 크기를 4로 설정, 탭을 공백으로 변환, 
vim_set =("set tabstop=4" "set shiftwidth=4" "set expandtab" "set number")      
     
# vim 설치
if command -v vim &> /dev/null; then
    echo "Vim is already installed."
else
    echo "Vim is not installed. Installing Vim..."
    sudo apt install -y vim
fi

for setting in "${vim_set[@]}"; do
    if grep -q "$setting" ~/.vimrc; then
        echo "'$setting' is already present in ~/.vimrc."
    else
        echo "$setting" >> ~/.vimrc
        echo "'$setting' added to ~/.vimrc."
    fi
done



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


