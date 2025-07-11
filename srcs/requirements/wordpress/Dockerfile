FROM alpine:3.21

RUN  apk update && \
     apk add --no-cache  \
     php84 \
     php84-fpm \
     php84-mysqli \
     php84-json \
     php84-curl \
     php84-dom \
     php84-exif \
     php84-fileinfo \
     php84-mbstring \
     php84-openssl \
     php84-xml \
     php84-zip \
     php84-phar \
     wget \
     mariadb-client shadow

RUN deluser www-data || true && \
    delgroup www-data || true && \
    addgroup -g 82 -S www-data && \
    adduser -u 82 -D -S -G www-data www-data

EXPOSE 9000

RUN ln -s /usr/bin/php84 /usr/bin/php

RUN wget -P / https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /wp-cli.phar && \
    mv /wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html

COPY ./conf/www.conf /etc/php84/php-fpm.d/www.conf

COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    ln -s /entrypoint.sh /usr/local/bin/entrypoint

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf *.gz && \
    mv wordpress/* . && \
    rm -rf wordpress/ *.tar.gz

RUN apk del wget

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html

ENTRYPOINT ["entrypoint"]