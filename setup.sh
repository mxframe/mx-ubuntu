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
# @banner http://patorjk.com/software/taag/
#
# Using the Bash Infinity Project/Framework
# @url https://github.com/niieani/bash-oo-framework
#
##############################################################################################################

# ================================================
# Include the Bash Infinity Project/Framework
# ================================================
. "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bash-infinity/lib/oo-bootstrap.sh"

# ================================================
# Import the utilities
# ================================================
import util/tryCatch
import util/exception # needed only for Exception::PrintException

try {
    # something...
    cp ~/test123 ~/test2
    # something more...
} catch {
    echo "The hard disk is not connected properly!"
    echo "Caught Exception:$(UI.Color.Red) $__BACKTRACE_COMMAND__ $(UI.Color.Default)"
    echo "File: $__BACKTRACE_SOURCE__, Line: $__BACKTRACE_LINE__"

    ## printing a caught exception couldn't be simpler, as it's stored in "${__EXCEPTION__[@]}"
    Exception::PrintException "${__EXCEPTION__[@]}"
}

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

echo 'hier';
exit;

# ================================================
# Check if running with root user
# ================================================
if [ ${USER} == 'root' ]; then
    echo -e "${BRed}Permission Denied !!!${RCol}"
    echo 'The script an not be run by root, because npm and oder packages may be not installed correct.'
    exit
fi

# ================================================
# Include the setup dialogs
# ================================================
. ./includes/dialogs/sudo.sh

# ================================================
# Check folder and move to /home/all
# ================================================
exit;
. ./includes/scripts/move-to-all.sh

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
