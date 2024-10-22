#!/bin/bash

# 오류 로그 기록 함수
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1"
}

# 시스템 정보 출력 함수
print_system_info() {
    echo "=========================="
    echo "         시스템 정보        "
    echo "=========================="
    
    echo "OS 정보:"
    if command -v cat &> /dev/null; then
        cat /etc/os-release || log_error "Failed to get OS information."
    else
        log_error "cat command not found."
    fi
    echo

    echo "CPU 정보:"
    if command -v lscpu &> /dev/null; then
        lscpu || log_error "Failed to get CPU information."
    else
        log_error "lscpu command not found."
    fi
    echo

    echo "메모리 정보:"
    if command -v free &> /dev/null; then
        free -h || log_error "Failed to get memory information."
    else
        log_error "free command not found."
    fi
    echo

    echo "NVIDIA GPU 정보:"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi || log_error "Failed to get NVIDIA GPU information."
    else
        log_error "nvidia-smi command not found."
    fi
    echo

    echo "CUDA 버전:"
    if command -v nvcc &> /dev/null; then
        nvcc -V || log_error "Failed to get CUDA version."
    else
        log_error "nvcc command not found."
    fi
    echo

    echo "RAID 디스크 정보:"
    if command -v sudo &> /dev/null && command -v mdadm &> /dev/null; then
        sudo mdadm --detail /dev/md0 || log_error "Failed to get RAID disk information."
    else
        log_error "sudo or mdadm command not found."
    fi
    echo "=========================="
}

# 메인 실행
print_system_info
