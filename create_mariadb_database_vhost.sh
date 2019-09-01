#!/bin/bash
#
# Description: Create database on MariaDB for Virtual Host on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.2
#
# Usage:
#   ./create_mariadb_database_vhost.sh vhost_config_file
#   vhost_config_file - Full path of config file of virtual host
# Example:
#   ./create_mariadb_database_vhost.sh /etc/httpd/conf.d/vhost.conf
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Check input date
if [ "$1" = "" ]; then
	log "ERROR" "The script requires input data"
	exit 1
fi

# Defines the variables
VHOST_CONFIG=$1
VHOST_USER=$(get_httpd_var $VHOST_CONFIG SuexecUserGroup)
VHOST_USER_HOME=$(/usr/bin/cat /etc/passwd | grep $VHOST_USER | cut -d ":" -f 6)
DB_NAME=db_$(echo $VHOST_USER | sed "s/[.-]/_/g")
DB_USER=$VHOST_USER

# Generate root password for MySQL
DB_PASSWORD=$(password 16)

# Require list
require mariadb-server no

# Create database
/usr/bin/mysql -e "CREATE DATABASE $DB_NAME;" > $0.log 2>&1
check_exit_code $? "Create database $DB_NAME"

# Create mysql user for localhost
/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME . * TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" > $0.log 2>&1
check_exit_code $? "Create mysql user for localhost"

# Create mysql user for 127.0.0.1
/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME . * TO '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';" > $0.log 2>&1
check_exit_code $? "Create mysql user for 127.0.0.1"

# Flush privileges
/usr/bin/mysql -e "FLUSH PRIVILEGES;" > $0.log 2>&1
check_exit_code $? "Flush privileges"

# Create ~/.my.cnf
log "INFO" "Creating ~/.my.cnf"
/usr/bin/cat <<EOF > $VHOST_USER_HOME/.my.cnf
[client]
host=127.0.0.1
user=$DB_USER
password=$DB_PASSWORD
database=$DB_NAME
EOF

log "INFO" "Done"
