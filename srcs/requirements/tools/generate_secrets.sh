#!/bin/sh

mkdir -p ./secrets

CREDENTIALS=./secrets/credentials.txt
DB_PASS=./secrets/db_password.txt
DB_ROOT_PASS=./secrets/db_root_password.txt

CURRENT_USER=$(whoami)
ENVP=./srcs/.env

read -p "User for mysql: " SQL_USER
echo "${SQL_USER}" > $CREDENTIALS

read -p "SQL DATABASE name: " DB
echo "SQL_DATABASE=${DB}" >> $ENVP

echo "$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" > $DB_PASS
echo "$(head /dev/urandom | tr -dc A-Za-z0-9-_ | head -c 16)" > $DB_ROOT_PASS
