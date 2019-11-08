#!/bin/bash

docker run -d --name nginx01 -p 80:80 --restart=always --cpus="2" --memory="1024m" --memory-swap="1500m" --oom-kill-disable --mount src=nginx-vol,dst=/usr/local/mysofts/nginx/html nginx:v1
