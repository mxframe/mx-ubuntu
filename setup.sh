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
needsSudoPermission

# ================================================
# Check folder and move to /home/all
# ================================================
checkPathAll
moveMxUbuntu

# ================================================
# Show the dialogs
# ================================================
pressKeyToContinue


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
