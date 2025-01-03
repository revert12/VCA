#!/usr/bin/python3
import socket

def handle_request(request):
    """HTTP 요청을 처리하고 응답을 생성하는 함수"""
    try:
        # 요청을 확인하여 GET 요청이 맞는지 확인
        lines = request.split("\r\n")
        method, path, _ = lines[0].split(" ")

        if method == "GET":
            # 응답 내용 작성 (간단한 HTML 페이지)
            response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
            <html>
                <head><title>HTTP 서버</title></head>
                <body><h1>안녕하세요, HTTP 서버입니다!</h1></body>
            </html>"""
        else:
            # 다른 HTTP 메서드는 처리하지 않음
            response = """HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/plain\r\n\r\nMethod Not Allowed"""
        
        return response
    except Exception as e:
        # 오류 처리
        return """HTTP/1.1 500 Internal Server Error\r\nContent-Type: text/plain\r\n\r\n서버 오류 발생"""

def start_http_server(host='0.0.0.0', port=7001):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(1)
    print(f"HTTP 서버가 {host}:{port}에서 대기 중입니다...")

    while True:
        client_socket, client_address = server_socket.accept()
        print(f"클라이언트 연결: {client_address}")

        # 클라이언트로부터 요청 받기
        request_data = client_socket.recv(1024).decode()

        print(f"받은 요청: {request_data}")

        # 요청을 처리하고 응답을 생성
        response = handle_request(request_data)

        # 클라이언트에 HTTP 응답 전송
        client_socket.send(response.encode())

        client_socket.close()

if __name__ == "__main__":
    start_http_server()
