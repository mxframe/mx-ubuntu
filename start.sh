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

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to this directory
cd "${pathBash}"

# ================================================
# Include the main functionality
# ================================================
. "${pathBash}/includes.sh"

# ================================================
# Include the config
# ================================================
#[[ ! -f "${pathBash}/config.sh" ]] && cp -rp "${pathBash}/config.example.sh" "${pathBash}/config.sh"
. "${pathBash}/config.sh"

# ================================================
# Read the options
# ================================================
readOptions $*

# ================================================
# Clear the screen
# ================================================
clearScreen

# ================================================
# Include the sudo dialog (if needed)
# ================================================
needsSudoPermission

# ================================================
# Install dialog
# ================================================
installDialog

# ================================================
# Ensure that packages directory is usable
# ================================================
ensurePackagesDirectory

# ================================================
# Start installation
# ================================================
install

# ================================================
# Start hardening
# ================================================
hardening

# ================================================
# Ensure that we have the default users
# ================================================
ensureDefaultUsers

# ================================================
# Exit the script
# ================================================
exitScript
