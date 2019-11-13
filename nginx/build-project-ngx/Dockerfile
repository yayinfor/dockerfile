FROM base-nginx:v1

ENV MYSOFT_DIR /usr/local/mysofts

COPY nginx.conf $MY_SOFTS_DIR/nginx/conf

ENV PATH $MY_SOFTS_DIR/nginx/sbin:$PATH
WORKDIR $MY_SOFTS_DIR/nginx


EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
