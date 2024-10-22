#!/bin/bash

# 의존성 SW, 그래픽 드라이버, CUDA 툴킷 설치

# 오류 로그를 위한 함수
log_error() {
    echo "Error: $1"
    exit 1
}


# CUDA 설치 함수
install_cuda() {
    # CUDA 경로 설정
    CUDA_PATH='export PATH=/usr/local/cuda/bin:$PATH'
    LD_LIBRARY_PATH='export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH'

    # CUDA 설치 확인
    if [ -d /usr/local/cuda ] || nvcc --version &> /dev/null; then
        echo "CUDA is already installed."

        # .bashrc에 설정이 이미 존재하는지 확인
        if ! grep -Fxq "$CUDA_PATH" ~/.bashrc; then
            echo "$CUDA_PATH" >> ~/.bashrc || log_error "Failed to update .bashrc"
            source ~/.bashrc || log_error "Failed to source .bashrc"
            echo "CUDA path added to .bashrc."
        else
            echo "CUDA path already exists in .bashrc."
        fi

        # LD_LIBRARY_PATH 설정 확인 및 추가
        if ! grep -Fxq "$LD_LIBRARY_PATH" ~/.bashrc; then
            echo "$LD_LIBRARY_PATH" >> ~/.bashrc || log_error "Failed to update .bashrc"
            source ~/.bashrc || log_error "Failed to source .bashrc"
            echo "LD_LIBRARY_PATH added to .bashrc."
        else
            echo "LD_LIBRARY_PATH already exists in .bashrc."
        fi
    else
        echo "CUDA is not installed. Starting installation."
        wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run || log_error "Failed to download CUDA installer"
        chmod +x cuda_11.8.0_520.61.05_linux.run || log_error "Failed to make CUDA installer executable"
        sudo sh cuda_11.8.0_520.61.05_linux.run || log_error "Failed to install CUDA"

        # 환경 변수 설정
        echo "$CUDA_PATH" >> ~/.bashrc || log_error "Failed to update .bashrc"
        echo "$LD_LIBRARY_PATH" >> ~/.bashrc || log_error "Failed to update .bashrc"
        
        # 변경 사항 적용
        source ~/.bashrc || log_error "Failed to source .bashrc"
    fi
}

# 전원 관련 서비스 비활성화
disable_power_services() {
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver lock-enabled false
}

# 자동 업데이트 비활성화 함수
disable_auto_updates() {
    AUTO_UPGRADE_FILE="/etc/apt/apt.conf.d/20auto-upgrades"

    # 파일이 존재하는지 확인
    if [[ -f "$AUTO_UPGRADE_FILE" ]]; then
        # 자동 업데이트 비활성화
        if grep -q 'APT::Periodic::Update-Package-Lists "1";' "$AUTO_UPGRADE_FILE" && grep -q 'APT::Periodic::Unattended-Upgrade "1";' "$AUTO_UPGRADE_FILE"; then
            echo "Auto updates are enabled. Disabling..."
            sudo cp "$AUTO_UPGRADE_FILE" "$AUTO_UPGRADE_FILE.bak" || log_error "Failed to backup auto-upgrades file"
            sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' "$AUTO_UPGRADE_FILE" || log_error "Failed to disable package list updates"
            sudo sed -i 's/APT::Periodic::Unattended-Upgrade "1";/APT::Periodic::Unattended-Upgrade "0";/' "$AUTO_UPGRADE_FILE" || log_error "Failed to disable unattended upgrades"
            echo "Auto updates have been disabled."
        else
            echo "Auto updates are already disabled."
        fi
    else
        log_error "File '$AUTO_UPGRADE_FILE' does not exist."
    fi
}

# 메인 실행
install_cuda
disable_power_services
disable_auto_updates

# CUDA 설치 확인
CUDA_VERSION=$(nvcc -V 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "CUDA installation successful."
    echo "$CUDA_VERSION"
    # 설치 파일 삭제
    rm -f cuda_11.7.0_515.43.04_linux.run || log_error "Failed to delete CUDA installer"
    echo "CUDA installer file deleted."
else
    echo "Installer file not found."
fi

echo "NVIDIA driver and CUDA 11.7 installation complete, environment variables set."
