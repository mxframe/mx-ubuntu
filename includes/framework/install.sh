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
