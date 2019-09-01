#!/bin/bash
#
# Description: Install WordPress 5.2 on Apache VHost on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.4
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
VHOST_USER_HOME=$(/usr/bin/cat /etc/passwd | grep $VHOST_USER | cut -d ":" -f 6)
WP_DOWNLOAD_LINK="https://wordpress.org/wordpress-5.2.zip"

# Get database vars $host, $user, $password, $database
source_ini $VHOST_USER_HOME/.my.cnf

# Require list
require wget
require unzip
require curl

# Download WordPress
/usr/bin/wget $WP_DOWNLOAD_LINK -O /tmp/wordpress.zip > $0.log 2>&1
check_exit_code $? "Download WordPress"

# Unzip WordPress
/usr/bin/unzip /tmp/wordpress.zip -d /tmp > $0.log 2>&1
check_exit_code $? "Unzip WordPress"

# Coping WordPress in Document Root
/usr/bin/cp -rf /tmp/wordpress/* $VHOST_DOC_ROOT > $0.log 2>&1
check_exit_code $? "Coping WordPress in Document Root"

# Create Wordpress config file
log "INFO" "Create Wordpress config file"
/usr/bin/cat <<EOF >> $VHOST_DOC_ROOT/wp-config.php
<?php
/**
 * The base configuration for WordPress.
 * This configuration file is automatically generated.
 */

// ** MySQL settings ** //
define( 'DB_NAME', '$database' );
define( 'DB_USER', '$user' );
define( 'DB_PASSWORD', '$password' );
define( 'DB_HOST', '$host' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', 'utf8_general_ci' );

// ** Authentication Unique Keys and Salts. ** //
$(/usr/bin/curl -s https://api.wordpress.org/secret-key/1.1/salt/)

// ** WordPress Database Table prefix. ** //
\$table_prefix = 'wp_';

//** For developers: WordPress debugging mode. ** //
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
EOF

# Set ownership in public_html
log "INFO" "Set ownership in public_html"
/usr/bin/chown $VHOST_USER:$VHOST_USER -R $VHOST_DOC_ROOT/*

log "INFO" "Done"
