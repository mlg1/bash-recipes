#!/bin/bash
#
# Description: Basic funtions for all recipes
# Author: Nedelin Petkov
# Version: 0.4
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
	/bin/rpm -qa | grep $REQU > /dev/null 2>&1
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
