#!/bin/bash

docker run -d --name nginx01 -p 80:80 --restart=always --cpus="1" --memory="512m" --memory-swap="1024m" --oom-kill-disable --mount src=nginx-vol,dst=/nginx/html nginx:v1
