#!/bin/sh

ENVP=./srcs/.env
CURRENT_USER=$(whoami)

echo "USER=${CURRENT_USER}" > $ENVP
echo "DOMAIN_NAME=${CURRENT_USER}.42.fr" >> $ENVP
echo "WP_ADMIN=${CURRENT_USER}" >> $ENVP
echo "WP_A_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> $ENVP
read -p "Wordpress Admin email: " WP_A_EMAIL
echo "WP_A_EMAIL=${WP_A_EMAIL}" >> $ENVP
read -p "WP_USER: " WP_USER
echo "WP_USER=${WP_USER}" >> $ENVP
echo "WP_U_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> $ENVP
read -p "Wordpress User email: " WP_U_EMAIL
echo "WP_U_EMAIL=${WP_U_EMAIL}" >> $ENVP