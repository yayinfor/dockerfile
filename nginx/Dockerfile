FROM centos:latest

# 注意，日志要重定向输出到stdout,否则无法看到容器日志输出
ENV NGINX_VERSION nginx-1.16.0
ENV NGINX_DOWNLOAD_RUL http://nginx.org/download/$NGINX_VERSION.tar.gz

ENV OPENSSL_VERSION openssl-1.1.1b
ENV OPENSSL_DOWNLOAD_URL https://www.openssl.org/source/$OPENSSL_VERSION.tar.gz

ENV MYSOFT_DIR /usr/local/mysofts 

RUN yum -y update 
RUN yum -y install gcc automake autoconf libtool make 
RUN yum -y install gcc gcc-c++
RUN yum -y install wget zlib* pcre pcre-devel

RUN mkdir -p $MYSOFT_DIR
RUN \
    cd /tmp && \
    wget $NGINX_DOWNLOAD_RUL && \
    tar -zxvf $NGINX_VERSION.tar.gz

RUN \
    cd /tmp && \
    wget $OPENSSL_DOWNLOAD_URL && \
    tar -zxvf $OPENSSL_VERSION.tar.gz 

RUN \
    cd /tmp/$NGINX_VERSION && \
    ./configure --prefix=$MY_SOFTS_DIR/nginx --with-http_v2_module --with-http_stub_status_module --with-http_ssl_module --with-stream --with-openssl=../$OPENSSL_VERSION make && make install

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
