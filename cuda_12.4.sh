#!/bin/bash

# 의존성 SW, 그래픽 드라이버, CUDA 툴킷 설치 및 제거 스크립트

# 오류 로그를 위한 함수
log_error() {
    echo "Error: $1" >&2
}

# CUDA 제거 함수
remove_cuda() {
    echo "Removing CUDA..."

    if [ -d /usr/local/cuda ]; then
        sudo rm -rf /usr/local/cuda* || log_error "Failed to remove /usr/local/cuda*"
        echo "CUDA directories removed."
    else
        echo "No CUDA directories found."
    fi

    # .bashrc에서 CUDA 관련 경로 제거
    sed -i '/\/usr\/local\/cuda\/bin/d' ~/.bashrc || log_error "Failed to remove PATH from .bashrc"
    sed -i '/\/usr\/local\/cuda\/lib64/d' ~/.bashrc || log_error "Failed to remove LD_LIBRARY_PATH from .bashrc"
    echo "CUDA environment variables removed from .bashrc."

    # .bashrc 적용
    . ~/.bashrc || log_error "Failed to source .bashrc after CUDA removal"
    echo "CUDA removal complete."
}

# CUDA 설치 함수
install_cuda() {
    echo "Installing CUDA..."

    if [ -d /usr/local/cuda ]; then
        echo "CUDA is already installed."
        return
    fi

    wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_550.54.14_linux.run || log_error "Failed to download CUDA installer"
    chmod +x cuda_12.4.0_550.54.14_linux.run || log_error "Failed to make CUDA installer executable"
    sudo ./cuda_12.4.0_550.54.14_linux.run || log_error "Failed to install CUDA"

    # .bashrc에 경로 추가
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo "CUDA paths added to .bashrc."

    # .bashrc 적용
    . ~/.bashrc || log_error "Failed to source .bashrc after CUDA installation"

    echo "CUDA installation complete."
}

# 전원 관리 서비스 비활성화 함수
disable_power_services() {
    echo "Disabling power management services..."
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    echo "Power management services disabled."
}

# 자동 업데이트 비활성화 함수
disable_auto_updates() {
    AUTO_UPGRADE_FILE="/etc/apt/apt.conf.d/20auto-upgrades"

    echo "Disabling auto updates..."
    if [ -f "$AUTO_UPGRADE_FILE" ]; then
        sudo cp "$AUTO_UPGRADE_FILE" "$AUTO_UPGRADE_FILE.bak" || log_error "Failed to backup auto-upgrades file"
        sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' "$AUTO_UPGRADE_FILE" || log_error "Failed to disable package list updates"
        sudo sed -i 's/APT::Periodic::Unattended-Upgrade "1";/APT::Periodic::Unattended-Upgrade "0";/' "$AUTO_UPGRADE_FILE" || log_error "Failed to disable unattended upgrades"
        echo "Auto updates have been disabled."
    else
        log_error "File '$AUTO_UPGRADE_FILE' does not exist."
    fi
}

# 메인 실행
case "$1" in
    remove)
        remove_cuda
        ;;
    install)
        install_cuda
        ;;
    *)
        echo "Usage: $0 {remove|install}"
        exit 1
        ;;
esac

disable_power_services
disable_auto_updates

echo "Script execution complete."
