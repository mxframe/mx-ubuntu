#!/bin/bash

# ================================================
# A security/hardening script
# ================================================
hardening() {
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
    # Turn off enforcing & selinux (needed)
    # ================================================
    turnOffEnforcing
    turnOffSelinux

    # ================================================
    # Call the hardening scripts
    # ================================================
    quickSecure

    # ================================================
    # Turn on selinux (needed)
    # ================================================
    turnOnSelinux
}
