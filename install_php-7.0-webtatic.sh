#!/bin/bash
#
# Description: Install PHP 7.0 from Webtatic on CentOS 7.x
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
        php70w-common php70w-cli php70w-bcmath php70w-dba php70w-embedded php70w-enchant \
        php70w-gd php70w-imap php70w-interbase php70w-intl php70w-ldap php70w-mbstring php70w-mcrypt \
        php70w-mysqlnd php70w-odbc php70w-opcache php70w-pdo php70w-pdo_dblib php70w-pear php70w-pgsql \
        php70w-process php70w-snmp php70w-soap php70w-tidy php70w-xml php70w-xmlrpc > $0.log 2>&1
check_exit_code $? "Install PHP 7.0"

log "INFO" "Done"
