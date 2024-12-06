#!/bin/bash

# 현재 로그인된 사용자 가져오기
USER=$(whoami)

# root로 실행된 경우 오류 메시지 출력 후 종료
if [ $USER == 'root' ]; then
    echo "This script does not require sudo. $0'"
    exit
fi


print_help() {
    echo "Usage: ./multi_vca_service.sh <VCA-Core file path>"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
}

# 인자가 없는 경우 또는 도움말 요청인 경우
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_help
    exit 0
fi

# 인자로 전달된 파일 경로를 변수에 저장
FILE_PATH=$1

# 서비스 파일 내용 생성 함수
create_service_file() {
    local core_number=$1
    local cuda_device=$2
    local cpu_node=$3

    cat <<EOL
[Unit]
Description=VCACore${core_number} Service
ConditionPathExists=/home/$USER/VCA-Core${core_number}/service/bin/vca-core-service
After=network.target

[Service]
Environment=VCA_DATA_DIR=/home/$USER/VCA-Core${core_number}/data
Environment=CUDA_VISIBLE_DEVICES=$cuda_device
LimitNOFILE=100000
#ExecStart=/usr/bin/taskset 0xFFFFFFFFFF /home/$USER/VCA-Core${core_number}/service/bin/vca-core-service -p 9091 --
ExecStart=/usr/bin/numactl --cpunodebind=$cpu_node --membind=$cpu_node /home/$USER/VCA-Core${core_number}/service/bin/vca-core-service -p 909${core_number} --
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOL
}





# 파일 경로 출력
# echo "File_Path: $FILE_PATH"

# 파일이 존재하는지 확인
if [ -f "$FILE_PATH" ]; then

	sudo apt-get install numactl curl libva-dev -y
	
	sudo mkdir -p /home/$USER/VCA-Core1/data /home/$USER/VCA-Core2/data

	sudo chown -R $USER:$USER /home/$USER/VCA-Core1 /home/$USER/VCA-Core2

	sudo $FILE_PATH --location=/home/$USER/VCA-Core1/service --no-service --core-port=8081 --manager-port=9091 --skip-license
	sudo $FILE_PATH --location=/home/$USER/VCA-Core2/service --no-service --core-port=8082 --manager-port=9092 --skip-license



	sudo timeout 2 /home/$USER/VCA-Core1/service/bin/vca-licensing-daemon > /dev/null 2>&1
	
	# VCACore1 서비스 파일 내용 생성
	service_contents_core1=$(create_service_file 1 0 0)

	# VCACore2 서비스 파일 내용 생성
	service_contents_core2=$(create_service_file 2 1 1)

	# 파일 경로 리스트
	file_paths=("/etc/systemd/system/vca1.service" "/etc/systemd/system/vca2.service")

	# 파일 생성 및 내용 쓰기 (sudo 사용)
	for i in "${!file_paths[@]}"; do
	    file_path=${file_paths[$i]}
	    content=${service_contents_core1}
	    
	    # 2번째 서비스는 core2 파일 내용으로 업데이트
	    if [ $i -eq 1 ]; then
		content=$service_contents_core2
	    fi

	    # sudo로 파일을 생성하기 위해서는 관리자 권한을 요구함
	    echo "$content" | sudo tee "$file_path" > /dev/null
	    if [ $? -eq 0 ]; then
		echo "서비스 파일이 $file_path에 성공적으로 생성되었습니다."
	    else
		echo "파일을 생성하는 중 오류가 발생했습니다: $file_path"
	    fi
	done

	sudo systemctl daemon-reload
	echo "Setting up vca1.service on port 8081"
	sudo systemctl start vca1.service
	sleep 5  # 충분한 대기 시간을 추가
	if systemctl is-active vca1.service; then
		cnt=0
		while [ 1 ]; do
			cnt=$((cnt+1))
			curl --digest -u admin:admin -X PUT "http://localhost:8080/api/settings/web_port" -H "Content-Type: application/json" -d 8081
			if [ $? -eq 0 ]; then
				break;
			fi
			if [ $cnt -eq 5 ]; then
				echo "ERROR: failed to change the port of vca1 service to 8081"
				exit
			fi
			sleep 2
		done
	else
		echo "ERROR: starting vca1.service"
		exit
	fi
	sleep 3

  echo "Setting up vca2.service on port 8082"
	sudo systemctl start vca2.service
	sleep 5		# 충분한 대기 시간을 추가
	if systemctl is-active vca2.service; then
		cnt=0
		while [ 1 ]; do
			cnt=$((cnt+1))
			curl --digest -u admin:admin -X PUT "http://localhost:8080/api/settings/web_port" -H "Content-Type: application/json" -d 8082
			if [ $? -eq 0 ]; then
				break;
			fi
			if [ $cnt -eq 5 ]; then
				echo "ERROR: failed to change the port of vca2 service to 8082"
				exit
			fi
			sleep 2
		done
	else
		echo "ERROR: starting vca2.service"
		exit
	fi
	sudo systemctl enable vca1.service
	sudo systemctl enable vca2.service
	echo "Setting complete"

else
    echo "Invalid file path"
fi
