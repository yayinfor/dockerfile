# 构建一个最基础的nginx镜像

### 1. 编写Dockerfile文件，源码构建nginx镜像
```
# 基础镜像使用alpine，只有几M，不要使用centos
FROM alpine:3.9

# nginx版本和下载地址
ENV NGINX_VERSION nginx-1.16.0
ENV NGINX_DOWNLOAD_RUL http://nginx.org/download/$NGINX_VERSION.tar.gz

# 设置阿里云alpine apk镜像，安装nginx所需依赖包，下载nginx源码并安装
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk --update add \
  build-base linux-headers openssl-dev pcre-dev wget zlib-dev \
  openssl pcre zlib && \
  cd /tmp && \
  wget $NGINX_DOWNLOAD_RUL && \
  tar -zxvf $NGINX_VERSION.tar.gz && \
  cd /tmp/$NGINX_VERSION && \
  ./configure \
    --prefix=/usr/local/nginx \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-ipv6 \
&& make && \
   make install && \
   adduser -D nginx && \
   rm -rf /tmp/*

# 将nginx执行文件目录添加到PATH环境变量
ENV PATH /usr/local/nginx/sbin:$PATH

# 将nginx home目录设置为容器工作目录
WORKDIR /usr/local/nginx

# 对外暴露nginx端口
EXPOSE 80 443

# 运行容器时执行nginx运行命令，daemon off;是禁止后台运行，
# 容器内的应用必须前台运行，否则容器启动后会立即退出
CMD ["nginx", "-g", "daemon off;"]
```

### 2. 编写build-base-ngx-image.sh文件，用于构建base-nginx:v1基础镜像，该镜像用于具体项目的基础镜像
```
#!/bin/bash

# 构建base-nginx:v1镜像
docker build -t base-nginx:v1 -f Dockerfile .
```
### 3. 构建镜像并查看镜像是否构建成功

```
# 构建镜像
./build-base-ngx-image.sh

#查看构建成功的base-nginx镜像
docker image ls

# 镜像列表中包含名称为base-nginx:v1的镜像即为构建成功
```

### 4. 运行基于nginx-base:v1镜像的容器

```
# 命令参数讲解：
# docker run: 运行容器
# -d: 后台运行
# --name nginx-base: 是指定容器名称为nginx-base
# -p 8080:80 : 指定宿主机端口映射容器端口，通过宿主机8080端口可访问容器中nginx的80端口
# --restart=always: 容器意外停止后，自动重启
# --cpus="1": 分配CPU的核心数
# --memory="512m": 分配内存为512m
# --memory-swap="1024m": 当容器内存不足时，最大可扩容到1024m, 宿主机会再分配512m给容器
# --oom-kill-disable: 内存不足时禁止杀掉容器
# nginx-base:v1 镜像名称

# 执行下面命令启动容器
docker run -d --name nginx-base -p 80:8080 --restart=always \
--cpus="1" --memory="512m" --memory-swap="1024m" --oom-kill-disable \
nginx-base:v1
```



cd build-base-ngx

// 因为源码安装openssl，安装时间会较长，大概5分钟左右
./build-base-ngx-image.sh

// 查看构建成功的base-nginx镜像
docker image ls

// 如何构建镜像可查看当前目录中的Dockerfile文件和./build-base-ngx-image.sh文件的内容
```

### 2. 在base-nginx:v1基础镜像上构建用于某个项目的nginx镜像
```
cd build-project-ngx

// 把nginx.conf里面的配置内容改为你项目需要的配置
vim nginx.conf 
// 修改配置内容...

// 我这里的项目叫epark, 开始构建项目所需的nginx镜像
// 可以将build-epark-ngx-image.sh中的nginx-epark改为你自己项目的名字
./build-epark-ngx-image.sh

// 查看构建成功的nginx-epark镜像
docker image ls

// nginx-epark和base-nginx不同的地方就是nginx.conf根据项目的需求做了配置

// 如何构建镜像可查看当前目录中的Dockerfile文件和./build-epark-ngx-image.sh文件的内容
```

### 3. 运行nginx-epark:v1镜像的容器
```
cd startup-project-ngx

// 运行容器
./start-nginx.sh

// 查看nginx-epark容器
docker ps

浏览器打开http://localhost

// 如何运行容器请查看当前目录中start-nginx.sh的内容
```

### 4. 部署项目和查看日志

```
// 查看start-nginx.sh源码内容
#!/bin/bash

docker run -d --name nginx-epark -p 80:80 --restart=always \
--cpus="1" --memory="512m" --memory-swap="1024m" --oom-kill-disable \
--mount src=ngx-epark-wwwroot,dst=/nginx/html \
--mount src=ngx-epark-logs,dst=/nginx/logs \
--mount src=ngx-epark-conf,dst=/nginx/conf \
nginx-epark:v1

#部署：复制index.html文件到数据卷ngx-epark-wwwroot宿主机目录
cp -rf index.html /var/lib/docker/volumes/ngx-epark-wwwroot/_data


从以上代码我们知道  
1. 挂载容器目录/nginx/html对应宿主机数据卷ngx-epark-wwwroot // 该目录存放着nginx web项目文件  
2. 挂载容器目录/nginx/logs对应宿主机数据卷ngx-epark-logs // 该目录存放着nginx日志文件  
3. 挂载容器目录/nginx/conf对应宿主机数据卷ngx-epark-conf // 该目录存放着nginx配置文件 
```

执行docker inspect nginx-epark, 从输出内容中找到Mounts信息如下：

```
"Mounts": [
    {
        "Type": "volume",
        "Name": "ngx-epark-wwwroot",
        "Source": "/var/lib/docker/volumes/ngx-epark-wwwroot/_data",
        "Destination": "/nginx/html",
        "Driver": "local",
        "Mode": "z",
        "RW": true,
        "Propagation": ""
    },
    {
        "Type": "volume",
        "Name": "ngx-epark-logs",
        "Source": "/var/lib/docker/volumes/ngx-epark-logs/_data",
        "Destination": "/nginx/logs",
        "Driver": "local",
        "Mode": "z",
        "RW": true,
        "Propagation": ""
    }
]
```

上面有2个Volume数据卷，  
通过Name为ngx-epark-wwwroot可以看出：  
宿主机目录在：/var/lib/docker/volumes/ngx-epark-wwwroot/_data  
容器目录在：/nignx/html  

通过Name为ngx-epark-logs可以看出：  
宿主机目录在：/var/lib/docker/volumes/ngx-epark-logs/_data  
容器目录在：/nginx/logs

#### 部署项目：  
只需要把项目文件拷贝到/var/lib/docker/volumes/ngx-epark-wwwroot/_data即可完成部署，  
此时容器目录/nignx/html中也会有最新部署的项目文件

可查看start-nginx.sh中如下代码片段，即为部署项目的方式
```
#部署：复制index.html文件到数据卷ngx-epark-wwwroot宿主机目录
cp -rf index.html /var/lib/docker/volumes/ngx-epark-wwwroot/_data
```

#### 查看日志：  
ls /var/nignx的lib/docker/volumes/ngx-epark-logs/_data即可看到里面有nignx的日志文件





 
