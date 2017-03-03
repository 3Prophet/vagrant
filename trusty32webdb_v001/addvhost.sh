#!/usr/bin/env bash

#This script adds new virtualhost to apache2 on ubuntu

hostname=$1
ext=".conf"
conffile=$hostname$ext
conffilepath=/etc/apache2/sites-available/$conffile
if [ ! -f $conffilepath ];
then
	cp /vagrant/skeleton $conffilepath
	sed -i "s/SKELETON/$hostname/g" $conffilepath

	a2ensite $conffile
	service apache2 reload
fi

