#!/usr/bin/python3

import subprocess
import os



def get_service_details(service_name):
    # 서비스의 상세 상태 확인 (systemctl status)
    try:
        result = subprocess.run(
            ['systemctl', 'status', f'{service_name}.service'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return result.stdout.strip()  # 상세 상태 반환
    except subprocess.CalledProcessError:
        return None  # 에러 발생 시 None 반환
    
def delete_service(service_name):
    # 서비스 삭제 (stop, disable, 서비스 파일 삭제)
    try:
        subprocess.run(['sudo', 'systemctl', 'stop', service_name], check=True)
        subprocess.run(['sudo', 'systemctl', 'disable', service_name], check=True)
        subprocess.run(['sudo', 'rm', f'/etc/systemd/system/{service_name}.service'], check=True)
        print(f"{service_name} 서비스가 삭제되었습니다.")
    except subprocess.CalledProcessError as e:
        print(f"서비스 삭제 중 오류가 발생했습니다: {e}")

def delete_folder():
    folder_paths = [
        '/opt/VCA-Core',
        '/var/opt/VCA-Core'
    ]  # 삭제할 폴더 경로

    # 각 폴더에 대해 삭제 시도
    for folder_path in folder_paths:
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




def main():
    service_name='vca-core'
    
    # 서비스 상태 확인

    status = get_service_details(service_name)
    
    if status is None:
        print(f"{service_name} 서비스는 존재하지 않거나 확인할 수 없습니다.")
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
    
    # 상태와 관계없이 삭제 여부 확인
    while True:
        delete_confirm = input(f"{service_name} 서비스를 삭제하시겠습니까? (y/n): ")
        if delete_confirm.lower() == 'y':
            delete_service(service_name)
            delete_folder()  # 서비스 삭제 후 폴더 삭제
            break
        elif delete_confirm.lower() == 'n':
            print(f"{service_name} 서비스 삭제가 취소되었습니다.")
            break
        else:
            print("잘못된 입력입니다. 'y' 또는 'n'을 입력해주세요.")

if __name__ == "__main__":
    main()
