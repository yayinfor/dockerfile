# nginx docker

### 1. 源码构建nginx基础镜像，用于具体项目的基础镜像

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





 
