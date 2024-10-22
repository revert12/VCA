#!/bin/bash

# bpytop 설치
if ! command -v bpytop &> /dev/null; then
    echo "Installing bpytop..."
    sudo apt-get update
    sudo snapd install -y bpytop
    echo "snapd, bpytop is already installed."
fi


###################################

