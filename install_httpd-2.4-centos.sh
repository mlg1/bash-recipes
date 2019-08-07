#!/bin/bash
#
# Description: Install httpd on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.2
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Require list
require epel-release

# Installing the necessary packages
/bin/yum install -y -q httpd mod_ssl mod_fcgid > $0.log 2>&1
check_exit_code $? "Install httpd, mod_ssl and mod_fcgid"

# Start and enable service
/usr/bin/systemctl start httpd > $0.log 2>&1
check_exit_code $? "Start 'httpd' service"

/usr/bin/systemctl enable httpd > $0.log 2>&1
check_exit_code $? "Enable to start on boot 'httpd' service"
