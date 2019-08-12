#!/bin/bash
#
# Description: Create Virtual host on httpd with mod_fcgid on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.1
#
# Usage:
#   ./create_httpd_vhost_fcgid.sh server_name server_alias
# Example:
#   ./create_httpd_vhost_fcgid.sh example.com www.example.com
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

# Defines the input variables
SERVER_NAME=$1
SERVER_ALIAS=$2
WEB_USER=app-$SERVER_NAME
CONF_FILE_NAME=$WEB_USER.conf

# Require list
require httpd no
require mod_ssl no
require mod_fcgid no
require php no

# Create user
log "INFO" "Create user $WEB_USER"
useradd -U -d /var/www/$WEB_USER $WEB_USER

# Create the necessary directories
log "INFO" "Create the necessary directories"
mkdir /var/www/$WEB_USER/cgi-bin
mkdir /var/www/$WEB_USER/php_sessions
mkdir /var/www/$WEB_USER/http_log
mkdir /var/www/$WEB_USER/public_html

# Create php.fcgi
log "INFO" "Create php.fcgi"
/usr/bin/cat <<EOF > /var/www/$WEB_USER/cgi-bin/php.fcgi
#!/bin/bash
# Shell Script to run PHP using mod_fcgid under Apache 2.x
PHP_FCGI_CHILDREN=0
PHP_FCGI_MAX_REQUESTS=10000
export PHP_FCGI_CHILDREN
export PHP_FCGI_MAX_REQUESTS
exec /usr/bin/php-cgi -c /var/www/$WEB_USER/cgi-bin/php.ini
EOF

# Make php.fcgi executable
log "INFO" "Make php.fcgi executable"
chmod +x /var/www/$WEB_USER/cgi-bin/php.fcgi

# Create php.ini
log "INFO" "Create php.ini"
cp /etc/php.ini /var/www/$WEB_USER/cgi-bin/

# Setting up php.ini
log "INFO" "Setting up php.ini"
sed -i -- 's/;error_log = php_errors.log/error_log = \/var\/www\/'$WEB_USER'\/http_log\/php_errors.log/g' /var/www/$WEB_USER/cgi-bin/php.ini
sed -i -- 's/;session.save_path = "\/tmp"/session.save_path = "\/var\/www\/'$WEB_USER'\/php_sessions"/g' /var/www/$WEB_USER/cgi-bin/php.ini
sed -i -- 's/;date.timezone =/date.timezone = '$(timedatectl | grep "Time zone" | cut -d " " -f 10 | sed "s/\//\\\\\//g")'/g' /var/www/$WEB_USER/cgi-bin/php.ini
sed -i -- 's/;open_basedir =/open_basedir = \/var\/www\/'$WEB_USER':\/usr\/share\/pear:\/usr\/share\/php:\/tmp:\/usr\/local\/share/g' /var/www/$WEB_USER/cgi-bin/php.ini


log "INFO" "Done"
