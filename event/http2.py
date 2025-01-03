#!/usr/bin/python3
import socket

def start_http_server(host='0.0.0.0', port=7001):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind((host, port))
    server_socket.listen(5)
    print(f"HTTP 서버가 {host}:{port}에서 대기 중입니다...")
    
    while True:
        client_socket, client_address = server_socket.accept()
        print(f"클라이언트 연결: {client_address}")
        
        try:
            # 요청의 첫 줄을 읽어서 메소드 확인
            request = client_socket.recv(1024)
            if not request:
                continue

            # 받은 요청 전체 출력
            request_data = request.decode('utf-8', errors='ignore')
            print(f"받은 요청: {request_data}")

            # 클라이언트로 받은 요청 데이터를 그대로 응답으로 전송
            response = (
                f"HTTP/1.1 200 OK\r\n"
                f"Content-Type: text/plain; charset=utf-8\r\n"
                f"Content-Length: {len(request_data.encode('utf-8'))}\r\n"
                f"Connection: close\r\n"
                f"\r\n"
                f"{request_data}"
            )
            client_socket.send(response.encode('utf-8'))
        
        except Exception as e:
            print(f"요청 처리 중 오류 발생: {e}")
            error_response = (
                "HTTP/1.1 500 Internal Server Error\r\n"
                "Content-Type: text/plain; charset=utf-8\r\n"
                "Content-Length: 21\r\n"
                "Connection: close\r\n"
                "\r\n"
                "서버 내부 오류 발생"
            ).encode('utf-8')
            client_socket.send(error_response)
        
        finally:
            client_socket.close()

if __name__ == "__main__":
    start_http_server()
