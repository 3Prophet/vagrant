#!/usr/bin/env bash

sudo apt-get update 2> /dev/null

sudo apt-get instlal -y apache2
sudo a2enmod rewrite

APACHEUSR=`grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars`
APACHEGRP=`grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars`
if [ APACHEUSR ]; then
    sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi
if [ APACHEGRP ]; then
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
fi

sudo chown -R vagrant:www-data /var/lock/apache2

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password ROOTPASSWORD'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ROOTPASSWORD'
sudo apt-get install -y mariadb-server 2> /dev/null
sudo apt-get install -y mariadb-client 2> /dev/null

if [ ! -f /var/log/dbinstalled ];
then
    echo "CREATE USER 'mariadbuser'@'localhost' IDENTIFIED BY 'USERPASSWORD'" | mysql -uroot -pROOTPASSWORD
    echo "CREATE USER 'mariadbuser'@'%' IDENTIFIED BY 'USERPASSWORD'" | mysql -uroot -pROOTPASSWORD
    echo "CREATE DATABASE test" | mysql -uroot -pROOTPASSWORD
    echo "GRANT ALL ON *.* TO 'mariadbuser'@'localhost'" | mysql -uroot -pROOTPASSWORD
    echo "GRANT ALL ON *.* TO 'mariadbuser'@'%'" | mysql -uroot -pROOTPASSWORD
    echo "flush privileges" | mysql -uroot -pROOTPASSWORD
    touch /var/log/dbinstalled
    if [ -f /vagrant/database/test.sql ];
    then
        mysql -uroot -pROOTPASSWORD internal < /vagrant/database/test.sql
    fi
fi

sudo apt-get install -y php5 php-pear php5-dev php5-gd php5-curl php5-mcrypt 2> /dev/null

# if /var/www is not a symlink then create the symlink and set up apache
if [ ! -h /var/www ];
then
    rm -rf /var/www
    ln -fs /vagrant /var/www
    sudo a2enmod rewrite 2> /dev/null
    sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
    sudo service apache2 restart 2> /dev/null
fi

# restart apache
sudo service apache2 reload 2> /dev/null