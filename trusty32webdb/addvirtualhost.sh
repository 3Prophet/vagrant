#!/usr/bin/env bash

hostname=$1
destination=/etc/apache2/sites-available/$hostname.conf

sudo cp /vagrant/skeleton $destination
sudo sed -i "s/SKELETON/$hostname/" $destination
