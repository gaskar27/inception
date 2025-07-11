FROM alpine:3.21

RUN apk update && \
    apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl /var/www/html

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
	-subj "/C=MG/ST=Antananarivo/L=Antananarivo/O=42/CN=localhost"

RUN chown -R root:root /var/www/html

#RUN chmod 755 /var/www/html && \
#    chown -R www-data:www-data /var/www/html

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN ln -s /entrypoint.sh /usr/local/bin/entrypoint

EXPOSE 443

ENTRYPOINT ["entrypoint"]
