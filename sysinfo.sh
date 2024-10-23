# 오류 로그 기록 함수
log_error() {
    echo "ERROR: $1"
}

# 시스템 정보 출력 함수
print_system_info() {
    echo "=========================="
    echo "         시스템 정보        "
    echo "=========================="

    echo "OS 정보:"
    if command -v awk &> /dev/null; then
        awk -F= '/^NAME/{print $2} /^VERSION/{print $2; exit}' /etc/os-release || log_error "OS 정보를 가져오는 데 실패했습니다."
    else
        log_error "awk 명령어를 찾을 수 없습니다."
    fi
    echo

    echo "CPU 모델명:"
    if command -v grep &> /dev/null; then
        grep -m 1 'model name' /proc/cpuinfo || log_error "CPU 정보를 가져오는 데 실패했습니다."
    else
        log_error "grep 명령어를 찾을 수 없습니다."
    fi
    echo

    echo "메모리 총량:"
    if command -v free &> /dev/null; then
        free -h | awk 'NR==2{print $2}' || log_error "메모리 정보를 가져오는 데 실패했습니다."
    else
        log_error "free 명령어를 찾을 수 없습니다."
    fi
    echo

    echo "NVIDIA GPU 이름 및 드라이버 버전:"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader || log_error "NVIDIA GPU 정보를 가져오는 데 실패했습니다."
    else
        log_error "nvidia-smi 명령어를 찾을 수 없습니다."
    fi
    echo

    echo "CUDA 버전:"
    if command -v nvcc &> /dev/null; then
        nvcc -V | grep "release" || log_error "CUDA 버전을 가져오는 데 실패했습니다."
    else
        log_error "nvcc 명령어를 찾을 수 없습니다."
    fi
    echo

    echo "=========================="
}

# 메인 실행
print_system_info
