#!/bin/bash
#
# Description: Basic funtions for all recipes
# Author: Nedelin Petkov
# Version: 0.7
#
# Exit codes:
# 0 - OK
# 1 - Error

# Function for output logging
# Example:
#   log "ERROR" "Installing httpd"
function log {
	LEVEL=$1
	MESSAGE=$2
	echo "$(date +"%b %d %H:%M:%S") $HOSTNAME $LEVEL: $MESSAGE"
}

# Function for check exit codes after every command
# Example:
#   /bin/yum install -y -q httpd
#   check_exit_code $? "Install httpd"
function check_exit_code {
	CODE=$1
	MESSAGE=$2
	if [ $CODE -ne 0 ]; then
		log "ERROR" "$MESSAGE"
		exit 1
	else
		log "INFO" "$MESSAGE"
	fi
}

# Function for requiring package
# Usage:
#   require packages_name install_packages_yes_or_no__default_yes
# Example:
#   require wget
#   require httpd no
function require {
	REQU=$1
	INSTALL=$2
	if [ "$INSTALL" = "" ]; then
		INSTALL="yes"
	fi
	/bin/rpm -qa | grep -i $REQU > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		log "WARN" "$REQU is not installed"
		if [ "$INSTALL" = "yes" ]; then
			/bin/yum install -y -q $REQU > /dev/null 2>&1
			check_exit_code $? "Installing '$REQU'"
		else
			log "ERROR" "$REQU is not installed"
			exit 1
		fi
	else
		log "INFO" "$REQU is installed"
	fi
}

# Function for password generating
# Example:
#   password 16
function password {
	LENGTH=$1
	date +"%s" | sha256sum | base64 -w 0 | head -c $LENGTH
}

# Function for parsing variables in apache config files
# Example:
#   get_httpd_var /etc/httpd/conf.d/vhost.conf DocumentRoot
function get_httpd_var {
	FILE=$1
	VAR=$2
	RETURN_VAR=$(grep '^[[:blank:]]*[^[:blank:]#;]' $FILE | awk '/<VirtualHost/ { var="" } /'$VAR'/ { var=$2 } /\/VirtualHost/ { print var }' | sort -u | xargs)
	if [ "$RETURN_VAR" = "" ]; then
		log "ERROR" "The '$VAR' variable was not found"
		exit 1
	else
		echo $RETURN_VAR
	fi
}

# Function for parsing variables from INI and CNF file
# Example:
#   source_ini /root/.my.cnf
#   echo $user
function source_ini {
	FILE=$1
	if [[ -f "$FILE" ]]; then
		source <(grep = $FILE)
	else
		log "ERROR" "$FILE is not exist"
		exit 1
	fi
}

# Function for get IPv4 address if missing returns "false"
function get_ipv4 {
	# Check route to google dns over IPv4
	IPV4_ROUTE=$(ip -o route get to 8.8.8.8)

	# Check for unreachable
	IPV4_UNREACH=$(echo $IPV4_ROUTE | grep "unreachable")

	if [ "$IPV4_UNREACH" = "" ]; then
		# Print IPv4 address
		echo $IPV4_ROUTE | sed -n 's/.*src \([0-9.]\+\).*/\1/p'
	else
		# No IPv4 address found
		echo "false"
	fi
}

# Function for get IPv6 address if missing returns "false"
function get_ipv6 {
	# Check route to google dns over IPv6
	IPV6_ROUTE=$(ip -o route get to 2001:4860:4860::8888)

	# Check for unreachable
	IPV6_UNREACH=$(echo $IPV6_ROUTE | grep "unreachable")

	if [ "$IPV6_UNREACH" = "" ]; then
		# Print IPv6 address
		echo $IPV6_ROUTE | sed -n 's/.*src \([a-zA-Z0-9:]\+\).*/\1/p'
	else
		# No IPv6 address found
		echo "false"
	fi
}
