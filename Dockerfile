FROM    alpine:3.17

RUN     apk --no-cache update && apk --no-cache upgrade \
        && apk add nginx nginx-mod-http-headers-more \
        && sed -i '/^[[:space:]]*http[[:space:]]*{.*/a \\tmore_clear_headers 'Server';\n\tmore_clear_headers 'X-Powered-By';\n' /etc/nginx/nginx.conf \
        && ln -sf /dev/sterr  /var/log/nginx/error.log \
        && ln -sf /dev/stdout /var/log/nginx/access.log \
	&& sed -i 's/listen\ \[::\]:80/#listen\ \[::\]:80/g' /etc/nginx/http.d/default.conf

CMD     ["nginx", "-g","daemon off;"]
