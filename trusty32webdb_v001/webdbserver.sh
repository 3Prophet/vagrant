#!/usr/bin/env bash

echo "Installing Apache and setting it up..."

apt-get update >/dev/null 2>&1
apt-get install -y apache2 >/dev/null 2>&1
rm -rf /var/www
ln -fs /vagrant /var/www
a2enmod rewrite 2> /dev/null

echo "Installing PHP..."

apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-mysql


#installing composer
apt-get -y install curl
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password password ROOTPASS'
debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password_again password ROOTPASS'

apt-get install -y mariadb-server
apt-get install -y mariadb-client

if [ ! -f /var/log/dbinstalled ];
then
	echo "CREATE USER 'mariadbuser'@'localhost' IDENTIFIED BY 'USERPASSWORD'" | mysql -uroot -pROOTPASS
	echo "CREATE USER 'mariadbuser'@'%' IDENTIFIED BY 'USERPASSWORD'" | mysql -uroot -pROOTPASS
	echo "CREATE DATABASE irs_dev" | mysql -uroot -pROOTPASS
	echo "GRANT ALL ON irs_dev.* TO 'mariadbuser'@'localhost'" | mysql -uroot -pROOTPASS
	echo "GRANT ALL ON irs_dev.* TO 'mariadbuser'@'%'" | mysql -uroot -pROOTPASS
	echo "flush privileges" | mysql -uroot -pROOTPASS
	touch /var/log/dbinstalled
	if [ -f /vagrant/database/test.sql ];
	then
		mysql -uroot -pROOTPASS irs_dev < /vagrant/database/test.sql
	fi
fi

# Adding virtual host
# Dont forget to add IP hostname pair to C\Windows\System32\drivers\etc\hosts
# or to /etc/hosts
hostname="irs-dev-vag.packimpex.ch"
/vagrant/addvhost.sh $hostname


/etc/init.d/apache2 restart
