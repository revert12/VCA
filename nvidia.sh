#!/bin/bash

# 의존성 SW, 그래픽 드라이버, 쿠다 툴킷 설치

sudo apt update || { echo "Failed to update package lists"; exit 1; }
sudo apt install -y nvidia-driver-550-server || { echo "Failed to install NVIDIA driver"; exit 1; }
wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run || { echo "Failed to download CUDA installer"; exit 1; }
chmod +x cuda_11.7.0_515.43.04_linux.run || { echo "Failed to make CUDA installer executable"; exit 1; }
sudo sh cuda_11.7.0_515.43.04_linux.run || { echo "Failed to install CUDA"; exit 1; }

# 환경 변수 설정

echo 'export PATH=/usr/local/cuda-11.7/bin:$PATH' >> ~/.bashrc || { echo "Failed to update .bashrc"; exit 1; }
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc || { echo "Failed to update .bashrc"; exit 1; }

# 변경 사항 적용

source ~/.bashrc || { echo "Failed to source .bashrc"; exit 1; }


# disable_auto_updates
# 자동 업데이트 설정 파일 경로
AUTO_UPGRADE_FILE="/etc/apt/apt.conf.d/20auto-upgrades"

# 스크립트 실행에 대한 권한 확인
if [[ $EUID -ne 0 ]]; then
echo "이 스크립트를 실행하려면 root 권한이 필요합니다." 
exit 1
fi

# 파일이 존재하는지 확인
if [[ -f "$AUTO_UPGRADE_FILE" ]]; then
# 자동 업데이트 비활성화
echo "자동 업데이트를 비활성화합니다..."
cp "$AUTO_UPGRADE_FILE" "$AUTO_UPGRADE_FILE.bak" || { echo "Failed to backup auto-upgrades file"; exit 1; }
sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' "$AUTO_UPGRADE_FILE" || { echo "Failed to disable package list updates"; exit 1; }
sed -i 's/APT::Periodic::Unattended-Upgrade "1";/APT::Periodic::Unattended-Upgrade "0";/' "$AUTO_UPGRADE_FILE" || { echo "Failed to disable unattended upgrades"; exit 1; }
echo "자동 업데이트가 비활성화되었습니다."
else
echo "파일 '$AUTO_UPGRADE_FILE'가 존재하지 않습니다."
fi

CUDA_VERSION=$(nvcc -V 2>/dev/null)

if [ $? -eq 0 ]; then
echo "CUDA가 정상적으로 설치되었습니다."
echo "$CUDA_VERSION"
# 설치 파일 삭제
rm -f cuda_11.7.0_515.43.04_linux.run || { echo "Failed to delete CUDA installer"; exit 1; }
echo "CUDA 설치 파일이 삭제되었습니다."
else
echo "설치 파일을 찾을 수 없습니다"
fi

echo "NVIDIA 드라이버 및 CUDA 11.7 설치 완료, 환경 변수 설정 완료."
