#!/bin/bash

# ================================================
# Function to check and request sudo permission
#
# @usage
# needsSudoPermission
# ================================================
needsSudoPermission() {
    # Check if we have sudo access
    if ! hasSudo
    then
        # First, check for an existing password
        if [[ $(echoOption 'sudopw') != false ]]
        then
            sudoPw=$(echoOption 'sudopw')
        fi

        # Check the sudo password
        sudoChecked=false
        if ! stringIsEmptyOrNull ${sudoPw}
        then
            # Try to activate sudo access
            activateSudo ${sudoPw}

            # Check if we have sudo access
            if hasSudo
            then
                sudoChecked=true
            else
                sudoPw=null
            fi
        fi

        # Check if we already have sudo access
        if ! ${sudoChecked}
        then
            # Check if we have sudo access
            if stringIsEmptyOrNull ${sudoPw}
            then
                # Show the sudo prompt
                showSudoPrompt
            fi

            # Check if we have sudo access
            if ! hasSudo
            then
                dumpError "Script needs to be run as root user, with sudo permission or the correct sudo password"
                exitScript
            fi
        fi
    fi
}

# ================================================
# Function to activate sudo permissions
#
# @usage
# activateSudo 'PASSWORD'
# ================================================
activateSudo() {
    dd "Activating sudo with password '$1'"
    try
    (
       (echo $1 | sudo -S ls >/dev/null 2>&1) || throw 100
    )
    catch || {
        return
    }
}

# ================================================
# Function to check if the script has sudo permissions
#
# @usage
# hasSudo
# ================================================
hasSudo() {
    try
    (
        if [[ ${USER} == 'root' ]]
        then
            dd "Testing for sudo. Result is true [#1]"
            return 0
        elif $(sudo -n true 2>/dev/null || throw 100)
        then
            dd "Testing for sudo. Result is true [#2]"
            return 0
        else
            throw 100
        fi
    )
    catch || {
        dd "Testing for sudo. Result is false"
        return 1
    }
}
