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
    # Print the info header
    # ================================================
    dumpInfoHeader 'Start Hardening'

    # ================================================
    # Update and upgrade the server
    # ================================================
    updateAndUpgrade
    return

    # ================================================
    # Turn off enforcing & selinux (needed)
    # ================================================
    dumpInfoLine 'Turn off enforcing'
    turnOffEnforcing
    dumpInfoLine 'Turn off selinux'
    turnOffSelinux

    # ================================================
    # Call the hardening scripts
    # ================================================
    hardeningWithTelemetry
    hardeningWithQuickSecure
    hardeningApache

    # ================================================
    # Turn on selinux (needed)
    # ================================================
    dumpInfoHeader 'Turn on selinux'
    turnOnSelinux
}
