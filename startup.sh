#!/bin/bash

# Check if /etc/apache2/sites-available is symlinked
if [[ -L /etc/apache2/sites-available ]]
then
    sudo rm -rf /etc/apache2/sites-available
    sudo ln -s /webcluster-share/apache2/sites-available /etc/apache2/sites-available
fi

# Check if /etc/apache2/sites-enabled is symlinked
if [[ -L /etc/apache2/sites-enabled ]]
then
    sudo rm -rf /etc/apache2/sites-enabled
    sudo ln -s /webcluster-share/apache2/sites-enabled /etc/apache2/sites-enabled
fi

# Restart apache
sudo service apache2 restart
