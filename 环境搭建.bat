::登录
echo input password:zsj18846299
docker login --username=brilli**** registry.cn-shenzhen.aliyuncs.com
:: 密码zsj18846299
echo continue ^?
pause
:: 拉取阿里云镜像
docker pull registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.2
pause

:: 创建容器，端口映射1278:22, 容器名myppocr
docker run --name mppocr -it -v C:\mntWin:/home/Projects/PaddleOCR/doc/imgs -p 1278:22 registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.2 /bin/bash