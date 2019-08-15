#!/bin/bash
#
# Description: Install WordPress 5.2 on Apache VHost on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.2
#
# Usage:
#   ./install_wordpress-5.2-httpd.sh vhost_config_file
#   vhost_config_file - Full path of config file of virtual host 
# Example:
#   ./install_wordpress-5.2-httpd.sh /etc/httpd/conf.d/vhost.conf
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
VHOST_SERVER_NAME=$(get_httpd_var $VHOST_CONFIG ServerName)
VHOST_DOC_ROOT=$(get_httpd_var $VHOST_CONFIG DocumentRoot)
VHOST_USER=$(get_httpd_var $VHOST_CONFIG SuexecUserGroup)
WP_DOWNLOAD_LINK="https://wordpress.org/wordpress-5.2.zip"

# Require list
require wget
require unzip

# Download WordPress
/usr/bin/wget $WP_DOWNLOAD_LINK -O /tmp/wordpress.zip > $0.log 2>&1
check_exit_code $? "Download WordPress"

# Unzip WordPress
/usr/bin/unzip /tmp/wordpress.zip -d /tmp > $0.log 2>&1
check_exit_code $? "Unzip WordPress"

# Coping WordPress in Document Root
/usr/bin/cp -rf /tmp/wordpress/* $VHOST_DOC_ROOT > $0.log 2>&1
check_exit_code $? "Coping WordPress in Document Root"

log "INFO" "Done"
