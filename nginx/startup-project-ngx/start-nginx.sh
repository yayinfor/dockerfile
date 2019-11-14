#!/bin/bash

docker run -d --name nginx-epark -p 80:80 --restart=always \
--cpus="1" --memory="512m" --memory-swap="1024m" --oom-kill-disable \
--mount src=ngx-epark-wwwroot,dst=/nginx/html \
--mount src=ngx-epark-logs,dst=/nginx/logs \
--mount src=ngx-epark-conf,dst=/nginx/conf \
nginx-epark:v1

# 复制index.html文件到数据卷ngx-epark-wwwroot宿主机目录
cp -rf index.html /var/lib/docker/volumes/ngx-epark-wwwroot/_data