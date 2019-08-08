#!/bin/bash
#
# Description: Install mysql(mariadb) server on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.2
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Installing the necessary packages
/bin/yum install -y -q mariadb mariadb-libs mariadb-server > $0.log 2>&1
check_exit_code $? "Install mariadb, mariadb-libs and mariadb-server"

# Start and enable service
/usr/bin/systemctl start mariadb > $0.log 2>&1
check_exit_code $? "Start 'mariadb' service"

/usr/bin/systemctl enable mariadb > $0.log 2>&1
check_exit_code $? "Enable to start on boot 'mariadb' service"

# Generate root password for MySQL
MYSQL_PASSWORD=$(password 16)

# Run mysql_secure_installation
log "INFO" "Running mysql_secure_installation"
/usr/bin/mysql_secure_installation > $0.log 2>&1 <<EOF

y
$MYSQL_PASSWORD
$MYSQL_PASSWORD
y
y
y
y
EOF

# Create ~/.my.cnf
log "INFO" "Creating ~/.my.cnf"
/usr/bin/cat <<EOF > ~/.my.cnf
[client]
user=root
password=$MYSQL_PASSWORD
EOF

log "INFO" "Done"
