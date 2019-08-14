#!/bin/bash
#
# Description: Install certbot on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.1
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Require list
require epel-release

# Installing the necessary packages
/bin/yum install -y -q certbot > $0.log 2>&1
check_exit_code $? "Install certbot"

# Register certbot
/usr/bin/certbot register --agree-tos --register-unsafely-without-email > $0.log 2>&1
check_exit_code $? "Register certbot"

log "INFO" "Done"
