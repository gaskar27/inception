FROM alpine:3.21

RUN apk update &&  \
    apk add --no-cache mariadb mariadb-client

EXPOSE 3306

#COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./conf/50-server.cnf /etc/my.cnf

COPY ./tools/entrypoint.sh /

ENV MARIADB_DATA_DIR /var/lib/mysql

RUN mkdir -p ${MARIADB_DATA_DIR} && \
    chown -R mysql:mysql ${MARIADB_DATA_DIR} && \
    chmod -R 700 ${MARIADB_DATA_DIR}

RUN chmod +x entrypoint.sh && \
    ln -s /entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
