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
