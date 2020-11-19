# docker版本OCR环境服务端搭建
************************
**目录**

[TOC]

## 1.windows下安装docker
*基本步骤：*
* [官网下载docker](https://www.docker.com/)

* 注册账号并安装
  - [x] docker下载镜像需要注册登录官方账号

## 2. 配置docker
* 添加阿里加速服务,配置文件如下
  *"https://jqa3j6qq.mirror.aliyuncs.com"**是我的阿里云加速服务地址***
  ``` json
  {
    "registry-mirrors": [
      "https://jqa3j6qq.mirror.aliyuncs.com"
    ],
    "insecure-registries": [],
    "debug": false,
    "experimental": false,
    "features": {
      "buildkit": true
    }
  } 
  ```
  - [x] windows下docker加速设置在此处修改
  ![docker 配置](../docker配置.png)


### [*脚本执行简化后续操作，点击跳转到第6步*](#6-执行脚本程序开启ocr服务)
## 3. 下载阿里云上的镜像到本地

*阿里云上传下载镜像暂使用个人账户*

  1. 登录阿里云Docker Registry
   
   > $ docker login --username=brilli**** registry.cn-shenzhen.aliyuncs.com

  - [X] password：zsj18846299

   > 用于登录的用户名为阿里云账号全名，密码为开通服务时设置的密码。

  2. 从Registry中拉取镜像到本机,2.1[^脚注]是版本号

   ```
   $ docker pull registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.2
   ``` 


  [^脚注]: **2.1**是镜像版本号

## 4. 使用镜像创建容器

  * 创建容器，并挂载主机文件到容器
    ```cmd
    #生成容器，端口映射1278:22, 容器名myppocr，完成文件挂载, C:\mntWin:/home/Projects/PaddleOCR/doc/imgs
    $docker run --name mppocr -it -v C:\mntWin:/home/Projects/PaddleOCR/doc/imgs -p 1278:22 registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.2 /bin/bash
    ```
## 5. 编写脚本执行服务程序

  * 编写Linux自启动脚本
    - [x] /home/shell_op/**op.sh**
    ```shell
    cd /home
    cd Projects/
    cd PaddleOCR/
    python3 tools/infer/predict_system.py --image_dir="./doc/imgs/" --det_model_dir="./inference/ch_ppocr_mobile_v1.1_det_infer/"  --rec_model_dir="./inference/ch_ppocr_mobile_v1.1_rec_infer/" --cls_model_dir="./inference/ch_ppocr_mobile_v1.1_cls_infer/" --use_angle_cls=True --use_space_char=True --use_gpu=False
    ```

  * 编写批处理文件
     - [x] **环境搭建.bat**
    ```bat
    ::登录
    echo input password:zsj18846299
    docker login --username=brilli**** registry.cn-shenzhen.aliyuncs.com
    :: 密码zsj18846299
    echo continue ^?
    pause
    :: 拉取阿里云镜像
    docker pull registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.1
    pause
    :: 创建容器，端口映射1278:22, 容器名
    docker run --name mppocr -it -v C:\mntWin:/home/Projects/PaddleOCR/doc/imgs -p 1278:22 registry.cn-shenzhen.aliyuncs.com/zzssjj/ubuntu_20_04_ocr:2.2 /bin/bash
    ```
  
      - [x] **PPOCR.bat**
    ```bat
    :: 注释：定义 var 变量，这个是容器的名字
    set var=test
    :: shell_op是linux容器中的脚本，被 docker exec 带参数执行，相当于Linux自启动脚本
    set shell_op=/home/shell_op/op.sh
    title ^START PPOCR
    echo statring container.....
    echo This is where the script executes inside the container: %shell_op%
    docker exec -it %var% /bin/bash %shell_op%
    echo end......
    PAUSE
    ```

## 6. 执行脚本程序开启OCR服务
* 执行[环境搭建.bat](./环境搭建.bat)
* 执行[PPOCR.bat](./PPOCR.bat),开启OCR服务

# 客户端搭建（示例）
  
###  客户端发出请求给服务端

- *windows CMD下执行*，端口号1278，localhost
  >$python httpclient.py 127.0.0.1 1278 ./doc/imgs/4.jpg
- **httpclient.py**
  ``` py
  import socket
  import sys

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
  ```

[//]: 图片预加载，将需要处理的图片存放到容器

# 说明

#### 1. 提供的端口是1278,[点击查看](#4-使用镜像创建容器)
  - *采取方式是docker容器的端口映射*
#### 2. 如何访问容器中的文件
 - **方式1**：使用docker cp指令，主机文件和docker容器文件互传
 - **方式2**：使用volume共享，创建容器时完成文件挂载[已经实现](#4-使用镜像创建容器)
 - **文件不能是加密的**，挂载加密文件在容器中不能正常打开
