#!/bin/bash
#
# Description: Install PHP 7.1 from Webtatic on CentOS 7.x
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
	php71w-common php71w-cli php71w-bcmath php71w-dba php71w-embedded php71w-enchant \
	php71w-gd php71w-imap php71w-interbase php71w-intl php71w-ldap php71w-mbstring php71w-mcrypt \
	php71w-mysqlnd php71w-odbc php71w-opcache php71w-pdo php71w-pdo_dblib php71w-pear php71w-pgsql \
	php71w-process php71w-snmp php71w-soap php71w-tidy php71w-xml php71w-xmlrpc > $0.log 2>&1
check_exit_code $? "Install PHP 7.1"

log "INFO" "Done"
