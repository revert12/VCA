#!/bin/bash

# Display OS version using /etc/os-release
echo "Operating System Information:"
cat /etc/os-release | grep -E 'NAME|VERSION'

# Display CPU info (model name and physical id)
echo -e "\nCPU Information:"
cat /proc/cpuinfo | grep -E "model name|physical id" | sort | uniq

# Display memory info
echo -e "\nMemory Information:"
free -h

# Check if NVIDIA GPU is present and driver is installed
if command -v nvidia-smi &>/dev/null; then
    echo -e "\nGPU Information:"
    # Display information for each GPU available in the system
    nvidia-smi --query-gpu=name --format=csv,noheader | nl
    # Display NVIDIA driver version
    echo -e "\nNVIDIA Driver Version:"
    nvidia-smi --query-gpu=driver_version --format=csv,noheader
else
    echo -e "\nNo NVIDIA GPU detected or NVIDIA driver is not installed."
fi

# Check for CUDA version using /usr/local/cuda/nvcc
if [ -f /usr/local/cuda/bin/nvcc ]; then
    echo -e "\nCUDA Version:"
    /usr/local/cuda/bin/nvcc --version | grep "release" | awk '{print $5}' | sed 's/,//g'
else
    echo -e "\nCUDA not installed or nvcc not found in /usr/local/cuda."
fi


# API 요청 보내기 (wget 사용)
response=$(wget -qO- --user=admin --password=admin http://127.0.0.1:8080/api/software.json)

# JSON 데이터에서 "string" 키에 해당하는 값만 추출
string_value=$(echo "$response" | grep -oP '"string":"[^"]+"' | sed 's/"string":"//g' | sed 's/"$//g')

echo -e "\nVCA Version:$string_value"

# API 요청 보내기 (wget 사용)
response=$(wget -qO- --user=admin --password=admin http://127.0.0.1:8002/api.json)

# JSON 데이터에서 "string" 키에 해당하는 값만 추출
string_value=$(echo "$response" | grep -oP '"string":"[^"]+"' | sed 's/"string":"//g' | sed 's/"$//g')

echo -e "Forensics MetDect Version:$string_value"

# API 요청 보내기 (wget 사용)
response=$(wget -qO- --user=admin --password=admin http://127.0.0.1:8080/api/licenses.json)

# 'vca' 항목 전체 추출 (중첩된 항목들도 모두 포함)
vca_info=$(echo "$response" | grep -oP '"vca":\{.*\}' | sed 's/\\//g')

# 각 라이센스에 대한 정보를 출력
for license_info in $(echo "$vca_info" | grep -oP '"\d+":\{.*?\}'); do
    # License ID 추출
    license_id=$(echo "$license_info" | grep -oP '"\d+"' | tr -d '"')
    
    # License 이름 추출
    license_name=$(echo "$license_info" | grep -oP '"name":"[^"]+"' | sed 's/"name":"//g' | sed 's/"$//g')

    # License 코드 추출
    license_code=$(echo "$license_info" | grep -oP '"code":\d+' | sed 's/"code"://g')

    # token 코드 추출 (하이픈 포함한 문자열 처리)
    license_token=$(echo "$license_info" | grep -oP '"token":"[^"]+"' | sed 's/"token":"//g' | sed 's/"$//g')
        
    # 'channels' 단일 값 처리
    channels=$(echo "$license_info" | grep -oP '"channels":\d+' | sed 's/"channels"://g')

    # 결과 출력
    echo "VCA License: "
    echo "License ID: $license_id"
    echo "License Name: $license_name"
    echo "License Code: $license_code"
    echo "License token: $license_token"
    echo "License Channels: $channels"
    echo "------------------------------"
done
# 'vca' 항목 출력 (디버깅용)
#echo "$vca_info"
