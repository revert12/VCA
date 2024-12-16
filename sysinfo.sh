#!/bin/bash
exec > sysinfo.txt 2>&1
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


# API (VCA Version Check)
response=$(wget -qO- --user=admin --password=admin http://127.0.0.1:8080/api/software.json)

if [ $? -eq 0 ]; then
    # VCA Version 값 추출
    string_value=$(echo "$response" | grep -oP '"string":"[^"]+"' | sed 's/"string":"//g' | sed 's/"$//g')
    echo -e "\nVCA Version:$string_value"
else
    echo "Error: Failed to fetch VCA version from the API. Skipping this step."
fi

# SSL 인증서 (Forensics Version Check)
server_cert=$(openssl s_client -connect 127.0.0.1:8000 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM)

if [ $? -eq 0 ]; then
    # Post 요청 (Forensics Version Check)
    response=$(wget -qO- \
      --ca-certificate=<(echo "$server_cert") \
      --method=POST \
      --header="Content-Type: application/json" \
      --body-data='{"id": "admin", "pw": "admin"}' \
      https://127.0.0.1:8000/v1/auth/login)

    # token 값 추출 (Forensics Version Check)
    token=$(echo "$response" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')

    if [ -n "$token" ]; then
        # Forensics Version 요청 (토큰 유효성 확인)
        version=$(wget -qO- \
          --ca-certificate=<(echo "$server_cert") \
          --method=GET \
          --header="Authorization: Bearer $token" \
          --header="Accept: application/json" \
          https://127.0.0.1:8000/v1/plugins/info | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')

        echo -e "Forensics Version: $version"
    else
        echo "Error: Token not found in the response. Skipping this step."
    fi
else
    echo "Error: Failed to fetch Forensics version from the API. Skipping this step."
fi

# API (VCA license Check)
response=$(wget -qO- --user=admin --password=admin http://127.0.0.1:8080/api/licenses.json)

if [ $? -eq 0 ]; then
    # vca total (VCA license Check)
    vca_info=$(echo "$response" | grep -oP '"vca":\{.*\}' | sed 's/\\//g')

    for license_info in $(echo "$vca_info" | grep -oP '"\d+":\{.*?\}'); do
        license_id=$(echo "$license_info" | grep -oP '"\d+"' | tr -d '"')
        license_name=$(echo "$license_info" | grep -oP '"name":"[^"]+"' | sed 's/"name":"//g' | sed 's/"$//g')
        license_code=$(echo "$license_info" | grep -oP '"code":\d+' | sed 's/"code"://g')
        license_=$(echo "$license_info" | grep -oP '"license":\s?"[^"]+"' | sed 's/"license":\s*"//g' | sed 's/"//g' | fold -w 50)
        license_token=$(echo "$license_info" | grep -oP '"token":"[^"]+"' | sed 's/"token":"//g' | sed 's/"$//g') 
        channels=$(echo "$license_info" | grep -oP '"channels":\d+' | sed 's/"channels"://g')

        # result
        echo -e "VCA License:"
        echo -e "License ID:$license_id"
        echo -e "License Name:$license_name"
        echo -e "License Code:$license_code"
        echo -e "License:\n$license_"
        echo -e "License token:$license_token"
        echo -e "License Channels:$channels"
        echo "------------------------------"
    done
else
    echo "Error: Failed to fetch VCA license Check from the API. Skipping this step."
fi
