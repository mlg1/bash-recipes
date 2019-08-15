#!/bin/bash
#
# Description: Install WordPress 5.2 on Apache VHost on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.1
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

echo "$VHOST_SERVER_NAME || $VHOST_DOC_ROOT |||| $VHOST_USER"

log "INFO" "Done"
