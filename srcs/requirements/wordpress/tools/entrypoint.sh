#!/bin/sh

#until nc -z mariadb 3306; do
#  echo "Waiting for database connection..."
#  sleep 1
#done

echo "Waiting for MariaDB to be ready..."
until mariadb -h mariadb -u "${SQL_USER}" -p"${SQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for MariaDB... (will retry in 5 seconds)"
    sleep 5
done
echo "MariaDB is ready!"

echo "Database is available. Starting WordPress setup."

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname=${SQL_DATABASE} \
        --dbuser=${USER} \
        --dbpass=${SQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root
fi

if ! wp core is-installed --allow-root; then
    echo "Installing WordPress core..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN}" \
        --admin_password="${WP_A_PASS}" \
        --admin_email="${WP_A_EMAIL}" \
        --allow-root
    echo "WordPress core installed."
fi

if ! wp user get "${WP_USER}" --allow-root &>/dev/null; then
    echo "Creating user '${WP_USER}'..."
    wp user create "${WP_USER}" "${WP_U_EMAIL}" \
        --user_pass="${WP_U_PASS}" \
        --role=editor \
        --display_name="Test" \
        --allow-root
    echo "User '${WP_USER}' created."
else
    echo "User '${WP_USER}' already exists. Skipping creation."
fi

exec php-fpm84 -F