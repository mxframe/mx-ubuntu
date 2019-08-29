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
# Clear the screen
# ================================================
clear
show_banner

# ================================================
# Include the sudo dialog (if needed)
# ================================================
needsSudoPermission

# ================================================
# Install dialog
# ================================================
installDialog

# ================================================
# Setup the users
# ================================================
#addUserWithPassword 'karl4' 'blau'
addUserWithPasswordAndKey 'carlos3' 'passwd' 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant public key'
exitScript

userSetup
exitScript

# ================================================
# Check folder and move to /home/all
# ================================================
###checkPathAll
###moveMxUbuntu

# ================================================
# Start installation
# ================================================
install
exitScript

# ================================================
# Start hardening
# ================================================
hardening





exitScript
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
