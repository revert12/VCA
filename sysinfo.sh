bash
# Error logging function
log_error() {
    echo "ERROR: $1"
}

# System information printing function
print_system_info() {
    echo "=========================="
    echo "         System Info        "
    echo "=========================="

    echo "OS Info:"
    if command -v awk &> /dev/null; then
        awk -F= '/^NAME/{print $2} /^VERSION/{print $2; exit}' /etc/os-release || log_error "Failed to retrieve OS information."
    else
        log_error "awk command not found."
    fi
    echo

    echo "CPU Model Name:"
    if command -v grep &> /dev/null; then
        grep -m 1 'model name' /proc/cpuinfo || log_error "Failed to retrieve CPU information."
    else
        log_error "grep command not found."
    fi
    echo

    echo "Total Memory:"
    if command -v free &> /dev/null; then
        free -h | awk 'NR==2{print $2}' || log_error "Failed to retrieve memory information."
    else
        log_error "free command not found."
    fi
    echo

    echo "NVIDIA GPU Name and Driver Version:"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader || log_error "Failed to retrieve NVIDIA GPU information."
    else
        log_error "nvidia-smi command not found."
    fi
    echo

    echo "CUDA Version:"
    if command -v nvcc &> /dev/null; then
        nvcc -V | grep "release" || log_error "Failed to retrieve CUDA version."
    else
        log_error "nvcc command not found."
    fi
    echo

    echo "=========================="
}

# Main execution
print_system_info
