FROM    alpine:3.17

RUN     apk --no-cache update && apk --no-cache upgrade \
        && apk add nginx nginx-mod-http-headers-more openssl \
        && sed -i '/^[[:space:]]*http[[:space:]]*{.*/a \\tmore_clear_headers 'Server';\n\tmore_clear_headers 'X-Powered-By';\n' /etc/nginx/nginx.conf \
        && ln -sf /dev/sterr  /var/log/nginx/error.log \
        && ln -sf /dev/stdout /var/log/nginx/access.log \
	&& sed -i 's/listen\ \[::\]:80/#listen\ \[::\]:80/g' /etc/nginx/http.d/default.conf \
	&& echo "NGINX IS WORKING" >  /var/www/localhost/htdocs/index.html \
	&& sed -i 's/return 404;/root  \/var\/www\/localhost\/htdocs;/g'    /etc/nginx/http.d/default.conf \
	&& sed -i 's@listen 80 default_server;@&\n\tlisten 443 ssl http2 default_server;\n\tssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;\n\tssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;@' /etc/nginx/http.d/default.conf \
	&& openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=mydomain.com" \
-addext "subjectAltName=DNS:mydomain.com" -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
	&& chown nginx:nginx /etc/ssl/private/nginx-selfsigned.key

#USER nginx

EXPOSE 80 443

CMD     ["nginx", "-g","daemon off;"]

