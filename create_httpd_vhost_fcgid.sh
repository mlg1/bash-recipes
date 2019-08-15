#!/bin/bash
#
# Description: Create Virtual host on httpd with mod_fcgid on CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.3
#
# Usage:
#   ./create_httpd_vhost_fcgid.sh server_name server_alias ssl_certificate
#   server_name - Server name
#   server_alias - Server alias
#   ssl_certificate - Add SSL. "own" or "letsencrypt"
# Example:
#   ./create_httpd_vhost_fcgid.sh example.com www.example.com letsencrypt
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Check input date
if [ "$2" = "" ]; then
	log "ERROR" "The script requires input data"
	exit 1
fi

# Defines the variables
SERVER_NAME=$1
SERVER_ALIAS=$2
SSL_CERT=$3
WEB_USER=app-$SERVER_NAME
WEB_USER_HOME_DIR=/var/www/$WEB_USER
HTTPD_CONF_FILE=/etc/httpd/conf.d/$WEB_USER.conf
SERVER_IP=$(hostname -i)

# Require list
require httpd no
require mod_fcgid no
require php no
if [ "$SSL_CERT" != "" ]; then
	require mod_ssl no
fi
if [ "$SSL_CERT" = "letsencrypt" ]; then
	require certbot no
fi

# Create user
log "INFO" "Create user $WEB_USER"
useradd -U -d $WEB_USER_HOME_DIR $WEB_USER

# Create the necessary directories
log "INFO" "Create the necessary directories"
mkdir $WEB_USER_HOME_DIR/cgi-bin
mkdir $WEB_USER_HOME_DIR/php_sessions
mkdir $WEB_USER_HOME_DIR/http_log
mkdir $WEB_USER_HOME_DIR/public_html

# Create php.fcgi
log "INFO" "Create php.fcgi"
/usr/bin/cat <<EOF > $WEB_USER_HOME_DIR/cgi-bin/php.fcgi
#!/bin/bash
# Shell Script to run PHP using mod_fcgid under Apache 2.x
PHP_FCGI_CHILDREN=0
PHP_FCGI_MAX_REQUESTS=10000
export PHP_FCGI_CHILDREN
export PHP_FCGI_MAX_REQUESTS
exec /usr/bin/php-cgi -c $WEB_USER_HOME_DIR/cgi-bin/php.ini
EOF

# Make php.fcgi executable
log "INFO" "Make php.fcgi executable"
/usr/bin/chmod +x $WEB_USER_HOME_DIR/cgi-bin/php.fcgi

# Create php.ini
log "INFO" "Create php.ini"
cp /etc/php.ini $WEB_USER_HOME_DIR/cgi-bin/

# Setting up php.ini
log "INFO" "Setting up php.ini"
/usr/bin/sed -i -- 's/;error_log = php_errors.log/error_log = \/var\/www\/'$WEB_USER'\/http_log\/php_errors.log/g' $WEB_USER_HOME_DIR/cgi-bin/php.ini
/usr/bin/sed -i -- 's/;session.save_path = "\/tmp"/session.save_path = "\/var\/www\/'$WEB_USER'\/php_sessions"/g' $WEB_USER_HOME_DIR/cgi-bin/php.ini
/usr/bin/sed -i -- 's/;date.timezone =/date.timezone = '$(timedatectl | grep "Time zone" | cut -d " " -f 10 | sed "s/\//\\\\\//g")'/g' $WEB_USER_HOME_DIR/cgi-bin/php.ini
/usr/bin/sed -i -- 's/;open_basedir =/open_basedir = \/var\/www\/'$WEB_USER':\/usr\/share\/pear:\/usr\/share\/php:\/tmp:\/usr\/local\/share/g' $WEB_USER_HOME_DIR/cgi-bin/php.ini

# Create phpinfo() in index.php
log "INFO" "Create phpinfo() in index.php"
echo "<?php phpinfo(); ?>" > $WEB_USER_HOME_DIR/public_html/index.php

# Set permissions and ownership on web user
log "INFO" "Set permissions and ownership on web user"
/usr/bin/chmod 710 $WEB_USER_HOME_DIR
/usr/bin/chown $WEB_USER:apache $WEB_USER_HOME_DIR
/usr/bin/chown $WEB_USER:$WEB_USER -R $WEB_USER_HOME_DIR/*

# Create virtual host config
log "INFO" "Create virtual host config"
/usr/bin/cat <<EOF > $HTTPD_CONF_FILE
# Automatically Generated on $(date +"%b %d %H:%M:%S")
<VirtualHost $SERVER_IP:80>
	ServerAdmin webmaster@$SERVER_NAME
	ServerName $SERVER_NAME
	ServerAlias $SERVER_ALIAS

	DocumentRoot "$WEB_USER_HOME_DIR/public_html"

	ErrorLog $WEB_USER_HOME_DIR/http_log/error.log
	CustomLog $WEB_USER_HOME_DIR/http_log/access.log combined

	SuexecUserGroup $WEB_USER $WEB_USER
	DirectoryIndex index.html index.php

	AddHandler fcgid-script .php .php7 .php5 .php4
	FCGIWrapper $WEB_USER_HOME_DIR/cgi-bin/php.fcgi .php

	<Directory "$WEB_USER_HOME_DIR/public_html">
		Options -Indexes +FollowSymLinks +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		AllowOverride All
	</Directory>

	# Add MIME types
	AddType application/font-sfnt		otf ttf
	AddType application/font-woff		woff
	AddType application/font-woff2		woff2
	AddType application/vnd.ms-fontobject	eot

	# Set deflate
	AddOutputFilterByType DEFLATE text/plain
	AddOutputFilterByType DEFLATE text/html
	AddOutputFilterByType DEFLATE text/xml
	AddOutputFilterByType DEFLATE text/css
	AddOutputFilterByType DEFLATE application/xml
	AddOutputFilterByType DEFLATE application/xhtml+xml
	AddOutputFilterByType DEFLATE application/rss+xml
	AddOutputFilterByType DEFLATE application/javascript
	AddOutputFilterByType DEFLATE application/x-javascript
	AddOutputFilterByType DEFLATE image/svg+xml

	# Add Expires
	ExpiresActive on
	ExpiresByType image/jpg				"access plus 12 month"
	ExpiresByType image/jpeg			"access plus 12 month"
	ExpiresByType image/gif				"access plus 12 month"
	ExpiresByType image/png				"access plus 12 month"
	ExpiresByType image/x-icon			"access plus 12 month"
	ExpiresByType image/vnd.microsoft.icon		"access plus 12 month"
	ExpiresByType image/svg+xml			"access plus 12 month"
	ExpiresByType text/css				"access plus 12 month"
	ExpiresByType application/javascript		"access plus 12 month"
	ExpiresByType application/font-woff		"access plus 12 month" 
	ExpiresByType application/font-woff2		"access plus 12 month"
	ExpiresByType application/font-sfnt		"access plus 12 month"
	ExpiresByType application/vnd.ms-fontobject	"access plus 12 month"

</VirtualHost>
EOF

# Restart httpd
/usr/bin/systemctl restart httpd > $0.log 2>&1
check_exit_code $? "Restart 'httpd' service"

# If we want to generate a Let's Encrypt certificate
if [ "$SSL_CERT" = "letsencrypt" ]; then
	log "INFO" "You want to generate a Let's Encrypt certificate"

	# Set variables
	LETS_CERT_DIR=/etc/letsencrypt/live/$SERVER_NAME

	# Generation of Let's Encrypt certificate
	/usr/bin/certbot certonly --webroot -w $WEB_USER_HOME_DIR/public_html -d $SERVER_NAME -d $SERVER_ALIAS > $0.log 2>&1
	check_exit_code $? "Generation of Let's Encrypt certificate"

	# Add ssl config in virtual host file
	log "INFO" "Add ssl config in virtual host file"
	/usr/bin/cat <<EOF >> $HTTPD_CONF_FILE
# Automatically Generated on $(date +"%b %d %H:%M:%S")
<VirtualHost $SERVER_IP:443>
	ServerAdmin webmaster@$SERVER_NAME
	ServerName $SERVER_NAME
	ServerAlias $SERVER_ALIAS

	DocumentRoot "$WEB_USER_HOME_DIR/public_html"

	ErrorLog $WEB_USER_HOME_DIR/http_log/ssl-error.log
	CustomLog $WEB_USER_HOME_DIR/http_log/ssl-access.log combined

	SuexecUserGroup $WEB_USER $WEB_USER
	DirectoryIndex index.html index.php

	AddHandler fcgid-script .php .php7 .php5 .php4
	FCGIWrapper $WEB_USER_HOME_DIR/cgi-bin/php.fcgi .php

	<Directory "$WEB_USER_HOME_DIR/public_html">
		Options -Indexes +FollowSymLinks +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		AllowOverride All
	</Directory>

	# Add MIME types
	AddType application/font-sfnt		otf ttf
	AddType application/font-woff		woff
	AddType application/font-woff2		woff2
	AddType application/vnd.ms-fontobject	eot

	# Set deflate
	AddOutputFilterByType DEFLATE text/plain
	AddOutputFilterByType DEFLATE text/html
	AddOutputFilterByType DEFLATE text/xml
	AddOutputFilterByType DEFLATE text/css
	AddOutputFilterByType DEFLATE application/xml
	AddOutputFilterByType DEFLATE application/xhtml+xml
	AddOutputFilterByType DEFLATE application/rss+xml
	AddOutputFilterByType DEFLATE application/javascript
	AddOutputFilterByType DEFLATE application/x-javascript
	AddOutputFilterByType DEFLATE image/svg+xml

	# Add Expires
	ExpiresActive on
	ExpiresByType image/jpg				"access plus 12 month"
	ExpiresByType image/jpeg			"access plus 12 month"
	ExpiresByType image/gif				"access plus 12 month"
	ExpiresByType image/png				"access plus 12 month"
	ExpiresByType image/x-icon			"access plus 12 month"
	ExpiresByType image/vnd.microsoft.icon		"access plus 12 month"
	ExpiresByType image/svg+xml			"access plus 12 month"
	ExpiresByType text/css				"access plus 12 month"
	ExpiresByType application/javascript		"access plus 12 month"
	ExpiresByType application/font-woff		"access plus 12 month" 
	ExpiresByType application/font-woff2		"access plus 12 month"
	ExpiresByType application/font-sfnt		"access plus 12 month"
	ExpiresByType application/vnd.ms-fontobject	"access plus 12 month"

	# SSL On
	SSLEngine on
	SSLProtocol all -SSLv2 -SSLv3
	SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256

	SSLCertificateFile $LETS_CERT_DIR/cert.pem
	SSLCertificateKeyFile $LETS_CERT_DIR/privkey.pem
	SSLCertificateChainFile $LETS_CERT_DIR/chain.pem

</VirtualHost>
EOF

	# Restart httpd
	/usr/bin/systemctl restart httpd > $0.log 2>&1
	check_exit_code $? "Restart 'httpd' service"
fi

# If we want to install own ssl certificate
if [ "$SSL_CERT" = "own" ]; then
	log "INFO" "You want to install own ssl certificate"

	# Set variables
	OWN_CERT_DIR=/etc/ssl/certs/$SERVER_NAME

	# Create certificate dir
	log "INFO" "Create certificate dir"
	/usr/bin/mkdir -p $OWN_CERT_DIR

	# Create empty certificate file
	/usr/bin/touch $OWN_CERT_DIR/cert.pem > $0.log 2>&1
	check_exit_code $? "Create empty certificate file"

	# Create empty private key file
	/usr/bin/touch $OWN_CERT_DIR/privkey.pem > $0.log 2>&1
	check_exit_code $? "Create empty private key file"

	# Create empty chain file
	/usr/bin/touch $OWN_CERT_DIR/chain.pem > $0.log 2>&1
	check_exit_code $? "Create empty chain file"

	log "INFO" "Add ssl config in virtual host file"
	/usr/bin/cat <<EOF >> $HTTPD_CONF_FILE
# Automatically Generated on $(date +"%b %d %H:%M:%S")
<VirtualHost $SERVER_IP:443>
	ServerAdmin webmaster@$SERVER_NAME
	ServerName $SERVER_NAME
	ServerAlias $SERVER_ALIAS

	DocumentRoot "$WEB_USER_HOME_DIR/public_html"

	ErrorLog $WEB_USER_HOME_DIR/http_log/ssl-error.log
	CustomLog $WEB_USER_HOME_DIR/http_log/ssl-access.log combined

	SuexecUserGroup $WEB_USER $WEB_USER
	DirectoryIndex index.html index.php

	AddHandler fcgid-script .php .php7 .php5 .php4
	FCGIWrapper $WEB_USER_HOME_DIR/cgi-bin/php.fcgi .php

	<Directory "$WEB_USER_HOME_DIR/public_html">
		Options -Indexes +FollowSymLinks +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		AllowOverride All
	</Directory>

	# Add MIME types
	AddType application/font-sfnt		otf ttf
	AddType application/font-woff		woff
	AddType application/font-woff2		woff2
	AddType application/vnd.ms-fontobject	eot

	# Set deflate
	AddOutputFilterByType DEFLATE text/plain
	AddOutputFilterByType DEFLATE text/html
	AddOutputFilterByType DEFLATE text/xml
	AddOutputFilterByType DEFLATE text/css
	AddOutputFilterByType DEFLATE application/xml
	AddOutputFilterByType DEFLATE application/xhtml+xml
	AddOutputFilterByType DEFLATE application/rss+xml
	AddOutputFilterByType DEFLATE application/javascript
	AddOutputFilterByType DEFLATE application/x-javascript
	AddOutputFilterByType DEFLATE image/svg+xml

	# Add Expires
	ExpiresActive on
	ExpiresByType image/jpg				"access plus 12 month"
	ExpiresByType image/jpeg			"access plus 12 month"
	ExpiresByType image/gif				"access plus 12 month"
	ExpiresByType image/png				"access plus 12 month"
	ExpiresByType image/x-icon			"access plus 12 month"
	ExpiresByType image/vnd.microsoft.icon		"access plus 12 month"
	ExpiresByType image/svg+xml			"access plus 12 month"
	ExpiresByType text/css				"access plus 12 month"
	ExpiresByType application/javascript		"access plus 12 month"
	ExpiresByType application/font-woff		"access plus 12 month" 
	ExpiresByType application/font-woff2		"access plus 12 month"
	ExpiresByType application/font-sfnt		"access plus 12 month"
	ExpiresByType application/vnd.ms-fontobject	"access plus 12 month"

	# SSL On
	SSLEngine on
	SSLProtocol all -SSLv2 -SSLv3
	SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256

	SSLCertificateFile $OWN_CERT_DIR/cert.pem
	SSLCertificateKeyFile $OWN_CERT_DIR/privkey.pem
	SSLCertificateChainFile $OWN_CERT_DIR/chain.pem

</VirtualHost>
EOF

	log "INFO" "  # Please add your certificate in $OWN_CERT_DIR/cert.pem"
	log "INFO" "  # Please add your private key in $OWN_CERT_DIR/privkey.pem"
	log "INFO" "  # Please add your certificate chain in $OWN_CERT_DIR/chain.pem"
	log "INFO" "  # Please restart your Apache with the command: systemctl restart httpd"
fi

log "INFO" "Done"
