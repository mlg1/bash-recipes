#!/bin/bash
#
# Description: Install PHP 7.2 from Webtatic on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.3
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Require list
require epel-release

# Install Webtatic repo
/bin/yum install -y -q https://mirror.webtatic.com/yum/el7/webtatic-release.rpm > $0.log 2>&1
check_exit_code $? "Install Webtatic repo"

# Installing the necessary packages
/bin/yum install -y -q \
	php72w-common php72w-cli php72w-bcmath php72w-dba php72w-embedded php72w-enchant \
	php72w-gd php72w-imap php72w-interbase php72w-intl php72w-ldap php72w-mbstring \
	php72w-mysqlnd php72w-odbc php72w-opcache php72w-pdo php72w-pdo_dblib php72w-pear php72w-pgsql \
	php72w-process php72w-snmp php72w-soap php72w-tidy php72w-xml php72w-xmlrpc > $0.log 2>&1
check_exit_code $? "Install PHP 7.2"

log "INFO" "Done"
