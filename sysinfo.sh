#!/bin/bash
exec > sysinfo.txt 2>&1

server_host=127.0.0.1
id=admin
pw=admin
# Function to fetch API data
fetch_data() {
    local url="$1"
    local user="$2"
    local password="$3"
    wget -qO- --user="$user" --password="$password" "$url"
}

# Function to extract value from JSON response using regex
extract_value() {
    local response="$1"
    local regex="$2"
    # Extract the matching value and remove unwanted parts
    echo "$response" | grep -oP "$regex" | sed -E 's/[^:]+:\s*"([^"]+)"/\1/'
}

# Function to process VCA License Information
process_license() {
	license_code=$(echo "$license_info" | grep -oP '"code":\d+' | sed 's/"code"://')
	channel_value=$(echo "$license_info" | grep -oP '"channels":\d+' | sed 's/"channels"://')
    local license_info="$1"
    
    echo -e "License ID: $(extract_value "$license_info" '"\d+"')"
    echo -e "License Name: $(extract_value "$license_info" '"name":"[^"]+"')"
    echo -e "License Code: $license_code"
    echo -e "License: $(extract_value "$license_info" '"license":\s?"[^"]+"'| fold -w 100)"
    echo -e "License Token: $(extract_value "$license_info" '"token":"[^"]+"')"
    echo -e "License Channels: $channel_value"
    echo "------------------------------"
}


# Display OS version using /etc/os-release
echo -e "\nOperating System Information:"
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


# SSL 인증서 (Forensics Version Check)
server_cert=$(openssl s_client -connect $server_host:8000 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM)
if [ $? -eq 0 ]; then
    # Post 요청 (Forensics Version Check)
	response=$(wget -qO- \
  	--ca-certificate=<(echo "$server_cert") \
  	--method=POST \
  	--header="Content-Type: application/json" \
  	--body-data="{\"id\": \"$id\", \"pw\": \"$pw\"}" \
  	https://$server_host:8000/v1/auth/login)
    # token 값 추출 (Forensics Version Check)
    token=$(echo "$response" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')

    if [ -n "$token" ]; then
        # Forensics Version 요청 (토큰 유효성 확인)
        version=$(wget -qO- \
          --ca-certificate=<(echo "$server_cert") \
          --method=GET \
          --header="Authorization: Bearer $token" \
          --header="Accept: application/json" \
          https://$server_host:8000/v1/about/server/version | grep -oP '"version": "\K[^"]+')

        if [[ "${version: -1}" == "n" ]]; then
    		# 마지막 문자가 'n'이면 끝에서 두 글자를 삭제
    		version="${version%??}"
    		echo -e "\nForensics version: $version"
		fi
    else
        echo "Error: Token not found in the response. Skipping this step."
    fi
else
    echo "Error: Failed to fetch Forensics version from the API."
fi


# Loop through ports 8080, 8081, and 8082
for port in 8080 8081 8082; do
    
    
    # API (VCA Version Check)
    response=$(fetch_data "http://$server_host:$port/api/software.json" "$id" "$pw")
    if [ $? -eq 0 ]; then
        string_value=$(extract_value "$response" '"string":"[^"]+"')
        echo -e "\n==== Checking Port $port ===="
        echo -e "\nVCA Version (Port $port): $string_value"
    fi

    # API (VCA GUID Check)
    response=$(fetch_data "http://$server_host:$port/api/hardware.json" "$id" "$pw")
    if [ $? -eq 0 ]; then
        guid=$(extract_value "$response" '"guid":"\K[^"]+')
        echo -e "Guid : $guid"
        echo "------------------------------"
    fi

    # API (VCA License Check)
    response=$(fetch_data "http://$server_host:$port/api/licenses.json" "$id" "$pw")
    if [ $? -eq 0 ]; then
        vca_info=$(echo "$response" | grep -oP '"vca":\{.*\}' | sed 's/\\//g')
        for license_info in $(echo "$vca_info" | grep -oP '"\d+":\{.*?\}'); do
            process_license "$license_info"
        done

    fi
done
