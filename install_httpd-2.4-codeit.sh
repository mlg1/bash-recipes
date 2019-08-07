#!/bin/bash
#
# Description: Install httpd with http2 on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.4
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Require list
require epel-release
require wget

# Download CodeIT repo
/usr/bin/wget https://repo.codeit.guru/codeit.el7.repo -P /etc/yum.repos.d/ > $0.log 2>&1
check_exit_code $? "Download CodeIT repo"

# Installing the necessary packages
/bin/yum install -y -q httpd mod_http2 mod_ssl mod_fcgid > $0.log 2>&1
check_exit_code $? "Install httpd, mod_http2, mod_ssl and mod_fcgid"

# Start and enable service
/usr/bin/systemctl start httpd > $0.log 2>&1
check_exit_code $? "Start 'httpd' service"

/usr/bin/systemctl enable httpd > $0.log 2>&1
check_exit_code $? "Enable to start on boot 'httpd' service"

log "INFO" "Done"
