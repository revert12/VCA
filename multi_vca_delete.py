#!/usr/bin/python3

import subprocess
import os
import sys

def get_service_details(service_name):
    # 서비스의 상세 상태 확인 (systemctl status)
    try:
        result = subprocess.run(
            ['systemctl', 'status', f'{service_name}.service'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return result.stdout.strip()  # 상태 반환
    except subprocess.CalledProcessError as e:
        return f"오류 발생: {e.stderr}"  # 오류 메시지 반환
    
def delete_service(service_name):
    # 서비스 삭제 (stop, disable, 서비스 파일 삭제)
    try:
        subprocess.run(['sudo', 'systemctl', 'stop', service_name], check=True)
        subprocess.run(['sudo', 'systemctl', 'disable', service_name], check=True)
        subprocess.run(['sudo', 'rm', f'/etc/systemd/system/{service_name}.service'], check=True)
    except subprocess.CalledProcessError as e:
        print(f"서비스 삭제 중 오류가 발생했습니다: {e.stderr}")

def delete_folder(folders):
    # 폴더 삭제
    for folder_path in folders:
            try:
                if os.path.exists(folder_path):
                    # sudo rm -rf 명령어로 폴더 삭제
                    subprocess.run(['sudo', 'rm', '-rf', folder_path], check=True)
                    print(f"폴더 '{folder_path}'이(가) 삭제되었습니다.")
                else:
                    print(f"폴더 '{folder_path}'이(가) 존재하지 않습니다.")
            except subprocess.CalledProcessError as e:
                print(f"폴더 '{folder_path}'을 삭제하는 중 오류 발생: {e}")
            except Exception as e:
                print(f"기타 오류 발생: {e}")

def get_user_confirmation(prompt):
    while True:
        user_input = input(prompt)
        if user_input.lower() == 'y':
            return True
        elif user_input.lower() == 'n':
            return False
        else:
            print("잘못된 입력입니다. 'y' 또는 'n'을 입력해주세요.")

def main():
    user = os.getenv('USER')
    if user == 'root':
        print(f"This script does not require sudo. {sys.argv[0]}")
        sys.exit()

    service_names = ['vca1', 'vca2']  # 확인할 서비스들

    # 각 서비스의 상태를 확인
    for service_name in service_names:
        status = get_service_details(service_name)
        
        if "오류 발생" in status:
            print(f"{service_name} 서비스 상태를 확인하는 데 문제가 발생했습니다: {status}")
        elif "active (running)" in status:
            print(f"{service_name} 서비스는 실행 중입니다.")
        elif "inactive (dead)" in status:
            print(f"{service_name} 서비스는 중지 상태입니다.")
        elif "failed" in status:
            print(f"{service_name} 서비스는 실패 상태입니다.")
        elif "activating" in status:
            print(f"{service_name} 서비스는 시작 중입니다.")
        elif "deactivating" in status:
            print(f"{service_name} 서비스는 중지 중입니다.")
        else:
            print(f"{service_name} 서비스 상태를 확인할 수 없습니다.")
    
    # 삭제 여부 확인
    if get_user_confirmation("모든 서비스를 삭제하시겠습니까? (y/n): "):
        for service_name in service_names:
            delete_service(service_name)
        
        # 폴더 삭제
        user = os.getenv('USER')
        delete_folder([f'/home/{user}/VCA-Core1', f'/home/{user}/VCA-Core2'])

if __name__ == "__main__":
    main()
