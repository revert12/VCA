#!/usr/bin/python3

import subprocess

# 1. xrdp 설치
def install_xrdp():
    try:
        subprocess.run(['sudo', 'apt', 'update'], check=True)
        subprocess.run(['sudo', 'apt', 'install', '-y', 'xrdp'], check=True)
        print("xrdp 설치 완료.")
    except subprocess.CalledProcessError as e:
        print(f"xrdp 설치 실패: {e}")

# 2. startwm.sh 파일 수정
def modify_startwm_sh():
    startwm_sh_path = '/etc/xrdp/startwm.sh'

    # 수정할 내용
    content_to_add = '''unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
. $HOME/.profile
'''

    try:
        # 파일을 열고 내용을 덧붙입니다.
        with open(startwm_sh_path, 'a') as file:
            file.write(content_to_add)
        print("startwm.sh 파일에 내용 추가 완료.")
    except IOError as e:
        print(f"파일 수정 실패: {e}")

# 3. xrdp 서비스 재시작
def restart_xrdp_service():
    try:
        subprocess.run(['sudo', 'systemctl', 'restart', 'xrdp'], check=True)
        print("xrdp 서비스가 재시작되었습니다.")
    except subprocess.CalledProcessError as e:
        print(f"xrdp 서비스 재시작 실패: {e}")

# xrdp 설치, startwm.sh 수정 및 서비스 재시작 실행
install_xrdp()
modify_startwm_sh()
restart_xrdp_service()
