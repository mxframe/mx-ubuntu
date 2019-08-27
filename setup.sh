#!/bin/bash

##############################################################################################################
#
# MxUbuntu - Server-Setup
# ======================
#
# Ubuntu Setup & Hardening Script
#
# Mathias Berg
# @homepage https://mx-progress.com
# @url https://github.com/mxframe/mx-ubuntu
#
##############################################################################################################

# ================================================
# Include the main functionality
# ================================================
. includes.sh

# ================================================
# Include the config
# ================================================
file_exists config.sh || cp -rp config.example.sh config.sh
. config.sh

# ================================================
# Read the options
# ================================================
readOptions $*

# ================================================
# Check if running with root user
# ================================================
if [ ${USER} == 'root' ]; then
    echo -e "${BRed}Permission Denied !!!${RCol}"
    echo 'The script an not be run by root, because npm and oder packages may be not installed correct.'
    exit
fi

# ================================================
# Include the sudo dialog
# ================================================
# First, check for an existing password
if [[ $(echoOption 'sudopw') != false ]]
then
    sudoPw=$(echoOption 'sudopw')
elif [[ ${isDevelopment} = true ]]
then
    sudoPw='test'
fi

# Check the sudo password
sudoChecked=false
if ! stringIsEmptyOrNull sudoPw
then
    # Try to activate sudo access
    activateSudo ${sudoPw}

    # Check if we have sudo access
    if hasSudo
    then
        sudoChecked=true
    else
        sudoPw=null
    fi
fi

# Check if we already have sudo access
if ! ${sudoChecked}
then
    # Check if we have sudo access
    if stringIsEmptyOrNull ${sudoPw}
    then
        # Show the sudo prompt
        showSudoPrompt
    fi

    # Check if we have sudo access
    if ! hasSudo
    then
        dumpError "Sudo password is incorrect"
    fi
fi

# ================================================
# Check folder and move to /home/all
# ================================================
checkPathAll
moveMxUbuntu

# ================================================
# Show the dialogs
# ================================================



exit
# ================================================
# Clear the screen & show the banner
# ================================================
clear
show_banner

# ================================================
# Update and upgrade the server
# ================================================
apt-get update -y
apt-get upgrade -y

# ================================================
# Install dialog
# ================================================
package_installed dialog || apt-get install dialog -y

# apt-get install kdelibs-bin -y
