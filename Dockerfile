FROM ivandreyv/alpine-aarch64:3.20.3

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="ivandreyv" \
    architecture="aarch64" \
    nginx-version="1.27.2" \
    alpine-version="3.20.3" \
    build="27-Nov-2024" \
    org.opencontainers.image.title="nginx-alpine" \
    org.opencontainers.image.description="Nginx container image running on Alpine Linux" \
    org.opencontainers.image.authors="ivandreyv" \
    org.opencontainers.image.vendor="ivandreyv" \
    org.opencontainers.image.version="1.27.2" \
    org.opencontainers.image.url="ivandreyv/nginx-alpine-aarch64:3.20.3" \
    org.opencontainers.image.source="https://github.com/ivandreyv/nginx-alpine" \
    org.opencontainers.image.base.name="ivandreyv/alpine-aarch64:3.20.3" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE

ENV NGINX_VERSION=1.27.2

RUN \
  build_pkgs="build-base linux-headers openssl-dev pcre-dev wget zlib-dev" && \
  runtime_pkgs="ca-certificates openssl pcre zlib tzdata git" && \
  apk --no-cache add ${build_pkgs} ${runtime_pkgs} && \
  cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar xzf nginx-${NGINX_VERSION}.tar.gz && \
  cd /tmp/nginx-${NGINX_VERSION} && \
  sed -i 's/"Server: nginx"/"Server: web-server"/g' src/http/ngx_http_header_filter_module.c && \
  sed -i 's/"Server: " NGINX_VER CRLF;/"Server: web-server" CRLF;/g' src/http/ngx_http_header_filter_module.c && \ 
  sed -i 's/#define NGINX_VER.*"nginx\/"/#define NGINX_VER          "web-server\/"/g' src/core/nginx.h && \
  sed -i 's/#define NGINX_VERSION.*"1.27.2"/#define NGINX_VERSION      "none"/g' src/core/nginx.h && \
  ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
#   --with-http_addition_module \
#   --with-http_sub_module \
#   --with-http_flv_module \
#   --with-http_mp4_module \
#   --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
#   --with-mail \
#   --with-mail_ssl_module \
    --with-file-aio \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-http_v2_module && \
  make && \
  make install && \
  sed -i -e 's/#access_log  logs\/access.log  main;/access_log \/dev\/stdout;/' -e 's/#error_log  logs\/error.log  notice;/error_log stderr notice;/' /etc/nginx/nginx.conf && \
  addgroup -S nginx && \
  adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
  rm -rf /tmp/* && \
  apk del ${build_pkgs} && \
  rm -rf /var/cache/apk/*  


COPY files/*.html /var/www/html/
COPY files/nginx.conf /etc/nginx/nginx.conf

RUN  find /etc/nginx -type f -exec chmod 640 {} \;

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx"]

