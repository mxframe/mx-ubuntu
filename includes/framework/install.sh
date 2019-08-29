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
        dumpInfoLine "${BYel}Already installed${RCol}"
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

    # Install the apache php mods
    sudo apt-get -y install libapache2-mod-php7.{1,3}

    # Use php7.3. with the cli
    sudo update-alternatives --set php /usr/bin/php7.3

    # Use php7.3 with apache2
    sudo a2dismod php7.*
    sudo a2enmod php7.3
    sudo service apache2 restart

    # Restart apache2
    sudo service apache2 restart

    # Install git
    sudo apt-get install -y git-core
    git config --global color.ui true
    sudo mkdir ${pathPackages}/.git
    sudo sh -c "echo '.*swp' > ${pathPackages}/.git/.gitignore_global"
    sudo rm -rf ${pathPackages}/.git/.gitignore_global
    sudo touch ${pathPackages}/.git/.git-credentials
    echo "${gitCredentials}" | sudo tee -a ${pathPackages}/.git/.git-credentials
    git config --global core.excludesfile ${pathPackages}/.git/.gitignore_global
    git config --global credential.helper "store --file ${pathPackages}/.git/.git-credentials"
    git config --system core.excludesfile ${pathPackages}/.git/.gitignore_global
    git config --system credential.helper "store --file ${pathPackages}/.git/.git-credentials"
}
