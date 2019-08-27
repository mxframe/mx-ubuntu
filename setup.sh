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
# Include the sudo dialog (if needed)
# ================================================
# Check if we have sudo access
if ! hasSudo
then
    # First, check for an existing password
    if [[ $(echoOption 'sudopw') != false ]]
    then
        sudoPw=$(echoOption 'sudopw')
    elif [[ ${isDevelopment} = true ]]
    then
        sudoPw='test123'
    fi

    # Check the sudo password
    sudoChecked=false
    if ! stringIsEmptyOrNull ${sudoPw}
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
            dumpError "Script needs to be run as root user, with sudo permission or the correct sudo password"
            exitScript
        fi
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
