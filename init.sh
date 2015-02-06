#!/bin/bash
PHP_TIMEZONE="Europe/Prague"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# apache install
apt-get -q -y install apache2

#
# MySQL with root:<no password>
#
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server

# php 5.6 install
echo "deb http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list
echo "deb-src http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list

wget http://www.dotdeb.org/dotdeb.gpg -O- |apt-key add -
apt-get update
apt-get -q -y install php5 php5-mysql php5-curl
a2enmod php5

#
# Utilities
#
sudo apt-get install -y make curl htop git-core vim

sudo php5enmod curl

#
# Composer for PHP
#
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#
# Update PHP Error Reporting
#
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/apache2/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini 
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/apache2/php.ini

sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/cli/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/cli/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/cli/php.ini

#
# MySQL Configuration
# Allow us to Remote from Vagrant with Port
#
sudo cp /etc/mysql/my.cnf /etc/mysql/my.bkup.cnf
# Note: Since the MySQL bind-address has a tab cahracter I comment out the end line
sudo sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/my.cnf

#
# Grant All Priveleges to ROOT for remote access
#
mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
sudo service mysql restart

#
# Apache VHost
#
cd ~
echo '<VirtualHost *:80>
        DocumentRoot /vagrant-www
</VirtualHost>

<Directory "/vagrant-www">
        Options Indexes Followsymlinks
        AllowOverride All
        Order allow,deny
        Allow from all
</Directory>' > vagrant

sudo mv vagrant /etc/apache2/sites-available
sudo a2enmod rewrite

#
# Reload apache
#
sudo a2ensite vagrant
sudo a2dissite 000-default
sudo service apache2 reload
sudo service apache2 restart