#!/bin/sh
set -e

mysql_install_db --user=mysql --ldata=/var/lib/mysql

service mysql start

if [ -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo " Database already exists: $MYSQL_DATABASE"
else
    echo " Configuring MySQL..."

    mysql -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;

        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    echo " MySQL initialized successfully."
fi

service mysql stop

exec "$@"
