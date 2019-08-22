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
# Check if running with root user
# ================================================
if [ "$USER" != "root" ]; then
      echo "Permission Denied"
      echo "Can only be run by root"
      exit
else
      # Clear the screen
      clear

      # Show the banner
      . includes/banner.sh
      f_banner
fi

# ================================================
# Include needed files
# ================================================
. includes/colors.sh

# ================================================
# Update and upgrade the server
# ================================================
apt-get update -y
apt-get upgrade -y

# ================================================
# Update and upgrade the server
# ================================================
apt-get install dialog -y

# apt-get install kdelibs-bin -y
