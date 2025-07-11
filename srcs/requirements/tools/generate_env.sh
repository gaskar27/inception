#!/bin/sh

ENVP=./srcs/.env
# Obtenir le nom d'utilisateur actuel
CURRENT_USER=$(whoami)

# Creer ou mettre a jour le fichier .env
echo "USER=${CURRENT_USER}" > ${ENVP}
echo "DOMAIN_NAME=${CURRENT_USER}.42.fr" >> ${ENVP}

read -p "SQL_USER: " SQL_USER
echo "SQL_USER=${SQL_USER}" >> ${ENVP}
read -p "SQL_DATABASE: " DB
echo "SQL_DATABASE=${DB}" >> ${ENVP}
echo "SQL_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> ${ENVP}
echo "SQL_ROOT_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> ${ENVP}

read -p "WP_ADMIN: " WP_ADMIN
echo "WP_ADMIN=${WP_ADMIN}" >> ${ENVP}
echo "WP_A_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> ${ENVP}
read -p "WP_A_EMAIL: " WP_A_EMAIL
echo "WP_A_EMAIL=${WP_A_EMAIL}" >> ${ENVP}
read -p "WP_USER: " WP_USER
echo "WP_USER=${WP_USER}" >> ${ENVP}
echo "WP_U_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" >> ${ENVP}
read -p "WP_U_EMAIL: " WP_U_EMAIL
echo "WP_U_EMAIL=${WP_U_EMAIL}" >> ${ENVP}
