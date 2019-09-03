#!/bin/bash
#
# Description: This script prepares the operating system for installation - CentOS 7.x
# Author: Nedelin Petkov
# Version: 0.1
#
# Exit codes:
# 0 - OK
# 1 - Error

# Load basic functions
source basic_func.sh

# Require list
require epel-release

# Disable SELinux
log "INFO" "Disable SELinux"
/usr/bin/sed -i -- 's/SELINUX=\([a-zA-Z0-9:]\+\)/SELINUX=disabled/g' /etc/selinux/config
/usr/sbin/setenforce 0 > $0.log 2>&1

# Install Firewalld
log "INFO" "Install Firewalld"
/bin/yum install -y -q firewalld firewalld-filesystem > $0.log 2>&1

# Start and enable Firewalld
log "INFO" "Start and enable Firewalld"
/usr/bin/systemctl start firewalld > $0.log 2>&1
/usr/bin/systemctl enable firewalld > $0.log 2>&1

# Install fail2ban
log "INFO" "Install fail2ban"
/bin/yum install -y -q fail2ban fail2ban-firewalld fail2ban-sendmail fail2ban-server > $0.log 2>&1

# Configure fail2ban
log "INFO" "Configure fail2ban"
/usr/bin/cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# Ban hosts for one hour:
bantime = 3600

# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport

[sshd]
enabled = true
EOF

# Start and enable fail2ban
log "INFO" "Start and enable fail2ban"
/usr/bin/systemctl start fail2ban > $0.log 2>&1
/usr/bin/systemctl enable fail2ban > $0.log 2>&1

log "INFO" "Done"
