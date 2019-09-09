#!/bin/bash

# ================================================
# A installation/setup script
# ================================================
install() {
#    # Verify the user wants to harden system
#    if ! getOption 'force'
#    then
#        echo -n "Are you sure you want to quick secure `hostname` (y/N)? "
#        read ANSWER
#        if [[ $ANSWER != "y" ]]
#        then
#            exitScript
#        fi
#
#        echo ''
#    fi

    # ================================================
    # Print the info header
    # ================================================
    dumpInfoHeader 'Start Installation'

    # ================================================
    # Update and upgrade the server
    # ================================================
    updateAndUpgrade

    # Create the backup directory
    if [[ ! -d /var/www/backups ]]
    then
        mkdir -p /var/www/backups >/dev/null 2>&1
    fi
    sudo chgrp -R www-data /var/www/backups
    sudo chmod -R g+s /var/www/backups
    sudo chown -R $(whoami) /var/www/backups

#    # Source the bash file
#    if [[ ! -L /etc/profile.d/mx-ubuntu.bashrc ]]
#    then
#        sudo rm -rf /etc/profile.d/mx-ubuntu.bashrc
#        sudo ln -s "${pathBash}/bashrc.sh" /etc/profile.d/mx-ubuntu.bashrc
#    fi

    # ================================================
    # Call the installation functions
    # ================================================
    tmpInstallEverything
}

# ================================================
# Install dialog
#
# @usage
# installDialog
#
# @info
# Dumps info lines
# ================================================
installDialog() {
    # Dump the intro line
    dumpInfoHeader 'Install dialog'

    # Check if the package is already installed
    if packageInstalled dialog
    then
        # Dump the info line
        dumpInfoLine "${BYel}Dialog is already installed${RCol}"
    else
        # Perform the installation
        sudo apt-get -q -qq install dialog -y 2>/dev/null

        # Dump the done line
        dumpInfoLine "${BGre}done${RCol}"
    fi
}

# ================================================
# Temporary Install function
#
# @usage
# tmpInstallEverything
# ================================================
tmpInstallEverything() {
    # Install default packages
    sudo apt-get -y install zip gzip unzip htop vim curl dos2unix multitail expect

    # Install some more sources for php
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update -y

    # Install mysql client
    sudo apt-get -y install mysql-client

    # Install apache2
    sudo apt-get -y install php apache2 apache2-utils
    # Setup apache
    sudo a2enmod rewrite ssl headers vhost_alias
    sudo timedatectl set-timezone Europe/Berlin
    sudo service apache2 restart

    # Install php
    sudo apt-get -y install php7.{1,3}-{bcmath,bz2,cgi,cli,common,curl,dev,dba,enchant,fpm,gd,gmp,imap,interbase,intl,json,ldap,mbstring,mysql,odbc,pgsql,phpdbg,pspell,readline,recode,snmp,soap,sqlite3,sybase,tidy,xml,xmlrpc,zip,opcache,xsl,xdebug}

    # Enable fcgi
    sudo apt-get -y install libapache2-mod-fastcgi php-pear
    sudo a2enmod actions fastcgi alias proxy_fcgi
    sudo service apache2 restart

    # Change owner
    sudo chown www-data:www-data /var/www/html
    sudo chgrp -R www-data /var/www/html
    sudo chmod -R 775 /var/www/html
    # https://askubuntu.com/questions/51951/set-default-group-for-user-when-they-create-new-files
    sudo chgrp -R www-data /var/www/html
    sudo chmod -R g+s /var/www/html
    sudo chown -R $(whoami) /var/www/html

    # Install the apache php mods
    sudo apt-get -y install libapache2-mod-php7.{1,3}

    # Use php7.3. with the cli
    sudo update-alternatives --set php /usr/bin/php7.3

    # Use php7.3 with apache2
    sudo a2dismod php7.1
    sudo a2enmod php7.3

    # Restart apache2
    sudo service apache2 restart

    # Install git
    sudo apt-get install -y git-core
    [[ ! -d ${pathPackages}/.git ]] && sudo mkdir ${pathPackages}/.git
    sudo sh -c "echo '.*swp' > ${pathPackages}/.git/.gitignore_global"
    # ... git-credentials
    sudo rm -rf ${pathPackages}/.git/.git-credentials
    sudo touch ${pathPackages}/.git/.git-credentials
    echo "${gitCredentials}" | sudo tee -a ${pathPackages}/.git/.git-credentials
    # ... global
    sudo git config --global color.ui true
    sudo git config --global core.excludesfile ${pathPackages}/.git/.gitignore_global
    sudo git config --global credential.helper "store --file ${pathPackages}/.git/.git-credentials"
    # ... system
    sudo git config --system color.ui true
    sudo git config --system core.excludesfile ${pathPackages}/.git/.gitignore_global
    sudo git config --system credential.helper "store --file ${pathPackages}/.git/.git-credentials"
    # chown and mod
    sudo chmod 660 "${pathPackages}/.git/.git-credentials" >/dev/null 2>&1
    sudo chown -R $(whoami):packages "${pathPackages}/.git" >/dev/null 2>&1

    # Install composer to /usr/local/bin/composer
    cd ~
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

    # Speed up composer
    composer global require hirak/prestissimo

    # Install node.js & npm
    # https://hackersandslackers.com/fixing-your-npm-installation/
    sudo apt-get -y remove node nodejs npm
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get -y install nodejs

    # Update npm to the latest version
    #sudo chown -R vagrant:vagrant node_modules/
    npm config set prefix "${pathPackages}/npm"
    npm install -g npm@latest

    # Install pretty errors
    npm install-g  pretty-error

    # Install nuxt
    npm install -g create-nuxt-app

    # Install vue CLI
    npm install -g @vue/cli

    # Install serve
    npm install -g serve

    # Activate npm/node server, proxy, etc.
    sudo a2enmod proxy proxy_http proxy_wstunnel
    sudo service apache2 restart
}
