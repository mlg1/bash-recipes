# bash-recipes
Bash recipes

Example for install WordPress:

./check_os.sh
./install_httpd-2.4-codeit.sh
./install_certbot-0.36-centos.sh
./install_php-7.2-webtatic.sh
./install_mariadb-10.4-mariadb.sh
./create_httpd_vhost_fcgid.sh example.com www.example.com letsencrypt
./create_mariadb_database_httpd.sh /etc/httpd/conf.d/app-example.com.conf
./install_wordpress-latest-httpd.sh /etc/httpd/conf.d/app-example.com.conf


Example for install Microweber:

./check_os.sh
./install_httpd-2.4-codeit.sh
./install_certbot-0.36-centos.sh
./install_php-7.2-webtatic.sh
./install_mariadb-10.4-mariadb.sh
./create_httpd_vhost_fcgid.sh example.com www.example.com letsencrypt
./create_mariadb_database_httpd.sh /etc/httpd/conf.d/app-example.com.conf
./install_microweber-latest-httpd.sh /etc/httpd/conf.d/app-example.com.conf
