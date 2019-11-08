FROM alpine:3.9

# nginx版本和下载地址
ENV NGINX_VERSION nginx-1.16.0
ENV NGINX_DOWNLOAD_RUL http://nginx.org/download/$NGINX_VERSION.tar.gz

# openssl版本和下载地址
ENV OPENSSL_VERSION openssl-1.1.1b
ENV OPENSSL_DOWNLOAD_URL https://www.openssl.org/source/$OPENSSL_VERSION.tar.gz
ENV MYSOFT_DIR /usr/local/mysofts 

# 设置阿里云alpine apk镜像
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

#安装gcc make等非nginx所需的包，可放入虚拟包中，待nginx编译完成再删除虚拟包，减少镜像文件的大小
RUN apk add --no-cache --virtual mypacks \
	gcc \
	libc-dev \
	make \
	openssl-dev \
	zlib-dev \
	linux-headers \
	curl \
	gnupg1 \
	libxslt-dev \
	gd-dev \
	geoip-dev \
&& apk add --no-cache \
	#安装第三方模块所需要的lua
	bash \
	pcre-dev \
	#安装设置时区的包
	tzdata 

# 安装nginx
RUN \
    # 下载nginx安装包
    mkdir -p $MYSOFT_DIR \
    && cd /tmp \
    && wget $NGINX_DOWNLOAD_RUL \
    && tar -zxvf $NGINX_VERSION.tar.gz \

    # 下载openssl安装包
    && cd /tmp \
    && wget $OPENSSL_DOWNLOAD_URL \
    && tar -zxvf $OPENSSL_VERSION.tar.gz \

    # 安装nginx
    && cd /tmp/$NGINX_VERSION \
    && ./configure --prefix=$MY_SOFTS_DIR/nginx --with-http_v2_module --with-http_stub_status_module --with-http_ssl_module --with-stream --with-openssl=../$OPENSSL_VERSION \
    && make \
    && make install \
    # 删除虚拟包 
    && apk del mypacks \
    # 删除nginx和openssl安装
    && rm -rf /tmp/*

COPY nginx.conf $MY_SOFTS_DIR/nginx/conf/nginx.conf
COPY index.html $MY_SOFTS_DIR/nginx/html/index.html

# 设置nginx可执行文件到path中
ENV PATH $MY_SOFTS_DIR/nginx/sbin:$PATH
WORKDIR $MY_SOFTS_DIR/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
