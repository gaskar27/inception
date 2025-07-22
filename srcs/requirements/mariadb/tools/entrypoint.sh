#!/bin/sh

MYSQLD="/usr/bin/mariadbd"
MYSQL="/usr/bin/mariadb"
MYSQLADMIN="/usr/bin/mariadb-admin"
MYSQL_INSTALL_DB="/usr/bin/mariadb-install-db"

SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
SQL_USER=$(cat /run/secrets/credentials)
SQL_PASSWORD=$(cat /run/secrets/db_password)
MARIADB_SOCKET_DIR="/run/mysqld"

mkdir -p "${MARIADB_SOCKET_DIR}"
chown mysql:mysql "${MARIADB_SOCKET_DIR}"
chmod 755 "${MARIADB_SOCKET_DIR}"

if [ ! -d "${MARIADB_DATA_DIR}/mysql" ]; then
    echo "Initializing MariaDB database for the first time in ${MARIADB_DATA_DIR}..."
    ${MYSQL_INSTALL_DB} --user=mysql --datadir="${MARIADB_DATA_DIR}" --auth-root-authentication-method=normal # Ensures root can connect initially without password

    echo "Starting MariaDB server temporarily for configuration..."
    ${MYSQLD} --user=mysql --datadir="${MARIADB_DATA_DIR}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" &
    MARIADB_PID=$!

    echo "Waiting for MariaDB temporary server to become ready via socket..."

    for i in $(seq 1 30); do
        ${MYSQLADMIN} -u root --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" ping >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "MariaDB temporary server is ready."
            break
        fi
        echo -n '.'
        sleep 1
    done

    if [ $? -ne 0 ]; then
        echo "Error: MariaDB temporary server did not start in time. Exiting."
        kill $MARIADB_PID
        exit 1
    fi

    echo "Running database configuration commands..."

    ${MYSQL} -u root --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'localhost';"

    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "FLUSH PRIVILEGES;"

    echo "Shutting down temporary MariaDB server..."
    ${MYSQLADMIN} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" shutdown
    wait $MARIADB_PID

    echo "MariaDB initial configuration complete."
else
    echo "MariaDB database already initialized."
fi

exec ${MYSQLD} --defaults-file=/etc/my.cnf --user=mysql --datadir="${MARIADB_DATA_DIR}" --bind-address=* --port=3306 --socket="${MARIADB_SOCKET_DIR}/mysqld.sock"
