#!/bin/bash
#
# Description: Install PHP 5.6 from Webtatic on CentOS 7.x
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
        php56w-common php56w-cli php56w-bcmath php56w-dba php56w-embedded php56w-enchant \
        php56w-gd php56w-imap php56w-interbase php56w-intl php56w-ldap php56w-mbstring php56w-mcrypt \
        php56w-mssql php56w-mysqlnd php56w-odbc php56w-opcache php56w-pdo php56w-pear php56w-pgsql \
        php56w-process php56w-snmp php56w-soap php56w-tidy php56w-xml php56w-xmlrpc > $0.log 2>&1
check_exit_code $? "Install PHP 5.6"
