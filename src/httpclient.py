import socket
import sys
#import os

#拷贝文件到docker 容器
#os.system("docker cp E:\PHP\configure.txt 4a2f08d2c1f8:/data1/configure.txt")
#  127.0.0.1 3878 ./doc/imgs/4.jpg
s = socket.socket()
#127.0.0.1,argv1是IP
host = sys.argv[1]
#32770 argv2是PORT
port =int(sys.argv[2])


s.connect((host, port))
ip, port = s.getsockname()
print("本机 ip 和 port {} {}".format(ip, port))

http_request = "GET / HTTP/1.1\r\nhost:{}\r\n\r\n".format(host)
#argv3是发送路径  ./doc/imgs/4.jpg
http_request1 = sys.argv[3]
request = http_request1.encode('utf-8')
print('请求', request)  
s.send(request)

response = s.recv(1023)
print('响应', response)
print('响应的 str 格式', response.decode('utf-8'))

s.close()



