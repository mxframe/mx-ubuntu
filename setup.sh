#!/bin/bash

##############################################################################################################
#
# MxFrame - Server-Setup
# ======================
#
# Linux Setup & Hardening Script
#
# Mathias Berg
# https://mx-progress.com
#
# Tool URL = https://github.com/mxframe/server-setup
#
# Banner by: http://patorjk.com/software/taag/
#
# Based on JShielder
# Credits Jason Soto
#
# - Based from JackTheStripper Project
# - Credits to Eugenia Bahit
#
# - A lot of Suggestion Taken from The Lynis Project
# - www.cisofy.com/lynis
# - Credits to Michael Boelen @mboelen
#
# - Credits to Center for Internet Security CIS
#
##############################################################################################################

# ================================================
# Include the functions
# ================================================
. functions.sh

# ================================================
# Include the config
# ================================================
file_exists config.sh || cp -rp config.example.sh config.sh
. config.sh

# ================================================
# Include the includes
# ================================================
. includes.sh

# ================================================
# Check if running with root user
# ================================================
if [ ${USER} == 'root' ]; then
    echo -e "${BRed}Permission Denied !!!${RCol}"
    echo 'The script an not be run by root, because npm and oder packages may be not installed correct.'
    exit
fi

echo $pwd
exit;

# ================================================
# Include the setup dialogs
# ================================================
. $HOME/bin/server-setup/includes/dialogs/sudo.sh

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
