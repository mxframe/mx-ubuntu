#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to this directory
cd "${pathBash}"

# Update this repo
./self-update.php

# Startup
# https://askubuntu.com/questions/814/how-to-run-scripts-on-start-up
# @reboot /usr/local/packages/mx-ubuntu/startup.sh


## Check if /etc/apache2/sites-available is symlinked
#if [[ ! -L /etc/apache2/sites-available ]]
#then
#    sudo rm -rf /etc/apache2/sites-available
#    sudo ln -s /webcluster-share/apache2/sites-available /etc/apache2/sites-available
#fi
#
## Check if /etc/apache2/sites-enabled is symlinked
#if [[ ! -L /etc/apache2/sites-enabled ]]
#then
#    sudo rm -rf /etc/apache2/sites-enabled
#    sudo ln -s /webcluster-share/apache2/sites-enabled /etc/apache2/sites-enabled
#fi
#
## Restart apache
#sudo service apache2 restart

## Check if /etc/apache2/sites-available is symlinked
#if [[ -L /etc/apache2/sites-available ]]
#then
#    sudo rm -rf /etc/apache2/sites-available
#    sudo cp -rp /webcluster-share/apache2/sites-available /etc/apache2/sites-available
#fi
#
## Check if /etc/apache2/sites-enabled is symlinked
#if [[ -L /etc/apache2/sites-enabled ]]
#then
#    sudo rm -rf /etc/apache2/sites-enabled
#    sudo cp -rp /webcluster-share/apache2/sites-enabled /etc/apache2/sites-enabled
#fi

# Restart apache
sudo service apache2 restart
