#!/usr/bin/python3
import socket

def start_tcp_server(host='0.0.0.0', port=7000):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(1)
    print(f"TCP 서버가 {host}:{port}에서 대기 중입니다...")

    while True:
        client_socket, client_address = server_socket.accept()
        print(f"클라이언트 연결: {client_address}")

        # 클라이언트로부터 메시지 받기
        data = client_socket.recv(1024).decode()
        print(f"받은 데이터: {data}")

        # 클라이언트에 응답 전송
        response = "서버 응답: 메시지를 받았습니다."
        client_socket.send(response.encode())

        client_socket.close()

if __name__ == "__main__":
    start_tcp_server()
