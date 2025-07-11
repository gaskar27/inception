#!/bin/sh

# Path to MariaDB binaries on Alpine (these are correct)
MYSQLD="/usr/bin/mariadbd"
MYSQL="/usr/bin/mariadb"
MYSQLADMIN="/usr/bin/mariadb-admin"
MYSQL_INSTALL_DB="/usr/bin/mariadb-install-db"

# --- CRITICAL: Define the data directory ---
MARIADB_DATA_DIR="/var/lib/mysql"
# --- CRITICAL: Define the socket directory ---
MARIADB_SOCKET_DIR="/run/mysqld"

# Ensure the socket directory exists and has correct permissions
mkdir -p "${MARIADB_SOCKET_DIR}"
chown mysql:mysql "${MARIADB_SOCKET_DIR}"
chmod 755 "${MARIADB_SOCKET_DIR}"

# Check if the database has already been initialized
# This check should look for a key file/directory created by mariadb-install-db,
# like the 'mysql' database directory within the data directory.
if [ ! -d "${MARIADB_DATA_DIR}/mysql" ]; then
    echo "Initializing MariaDB database for the first time in ${MARIADB_DATA_DIR}..."
    ${MYSQL_INSTALL_DB} --user=mysql --datadir="${MARIADB_DATA_DIR}" --auth-root-authentication-method=normal # Ensures root can connect initially without password

    echo "Starting MariaDB server temporarily for configuration..."
    # Start the temporary server. It will use the Unix socket for initial config.
    # It doesn't need to bind to the network at this stage.
    ${MYSQLD} --user=mysql --datadir="${MARIADB_DATA_DIR}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" &
    MARIADB_PID=$!

    echo "Waiting for MariaDB temporary server to become ready via socket..."
    for i in $(seq 1 30); do
        # Connect as root without password to the socket for initial setup
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

    # Set password for root user. This makes root@localhost require the password.
    ${MYSQL} -u root --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    # --- ALL SUBSEQUENT MYSQL COMMANDS AS ROOT MUST USE -p"..." ---

    # Create the database for WordPress
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

    # Create the WordPress user and grant privileges
    # Use SQL_USER here for clarity and to avoid conflicts with shell's USER env var
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

    # It's also good practice to grant access for the SQL_USER from localhost
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'localhost';"

    ${MYSQL} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" -e "FLUSH PRIVILEGES;"

    echo "Shutting down temporary MariaDB server..."
    # Ensure mariadb-admin also uses the root password after it's set
    ${MYSQLADMIN} -u root -p"${SQL_ROOT_PASSWORD}" --socket="${MARIADB_SOCKET_DIR}/mysqld.sock" shutdown
    wait $MARIADB_PID

    echo "MariaDB initial configuration complete."
else
    echo "MariaDB database already initialized."
fi

echo "Starting MariaDB server as main process..."
#exec ${MYSQLD} --user=mysql --datadir="${MARIADB_DATA_DIR}" --bind-address=* --port=3306 --socket="${MARIADB_SOCKET_DIR}/mysqld.sock"
exec ${MYSQLD} --defaults-file=/etc/my.cnf --user=mysql --datadir="${MARIADB_DATA_DIR}" --bind-address=* --port=3306 --socket="${MARIADB_SOCKET_DIR}/mysqld.sock"
