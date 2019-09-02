#!/bin/bash
#
# Description: Install latest Microweber on Apache VHost on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.1
#
# Usage:
#   ./install_microweber-latest-httpd.sh vhost_config_file
#   vhost_config_file - Full path of config file of virtual host 
# Example:
#   ./install_microweber-latest-httpd.sh /etc/httpd/conf.d/vhost.conf
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
VHOST_USER_HOME=$(/usr/bin/cat /etc/passwd | grep $VHOST_USER | cut -d ":" -f 6)
MW_DOWNLOAD_LINK="https://microweber.org/download.php"

# Get database vars $host, $user, $password, $database
#source_ini $VHOST_USER_HOME/.my.cnf

# Require list
require wget
require unzip
require curl

# Download Microweber
/usr/bin/wget $MW_DOWNLOAD_LINK -O /tmp/microweber.zip > $0.log 2>&1
check_exit_code $? "Download Microweber"

# Unzip Microweber in Document Root
/usr/bin/unzip /tmp/microweber.zip -d $VHOST_DOC_ROOT > $0.log 2>&1
check_exit_code $? "Unzip Microweber in Document Root"



# Set ownership in Document Root
log "INFO" "Set ownership in Document Root"
/usr/bin/chown $VHOST_USER:$VHOST_USER -R $VHOST_DOC_ROOT

log "INFO" "Done"
