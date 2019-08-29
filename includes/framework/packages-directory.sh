#!/bin/bash

# ================================================
# Ensure that the packages directory exist,
# the script runs in it and the groups are
# existing
# ================================================
ensurePackagesDirectory() {
    # Print the message
    dumpInfoHeader "Checking packages directory '${pathPackages}'"

    # Check the packages path
    __checkPathPackages

    # Check if the packages group exists
    if [[ $(groupExists "${groupPackages}") = false ]]
    then
        # Create the group
        dumpInfoLine "${BBlu}Info${RCol}: Creating the group '${groupPackages}'"
        try
        (
            # Add the group
            sudo groupadd ${groupPackages} >/dev/null 2>&1 || throw 100

            # Dump the info
            dumpInfoLine "... ${BGre}done${RCol}"
        )
        catch || {
            case ${exCode} in
                100)
                    dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the group '${groupPackages}'"
                ;;

                *)
                    dumpInfoLine "${BRed}Error${RCol}: There was an unknown error"
                ;;
            esac
            exitScript
        }
    fi

    # Ensure that the packages path has the correct permissions
    try
    (
        # Change the permissions
        dumpInfoLine "Change the permissions of path '${pathPackages}' to '${permissionPackages}'"
        sudo chmod -R ${permissionPackages} ${pathPackages} >/dev/null 2>&1 || throw 100

        # Change the owners
        dumpInfoLine "Change the owners of path '${pathPackages}' to '$(whoami):${groupPackages}'"
        sudo chown -R $(whoami):${groupPackages} ${pathPackages} >/dev/null 2>&1 || throw 101

        # Change creation of new stuff
        dumpInfoLine "Change the permanent group to '${groupPackages}'"
        sudo chgrp ${groupPackages} ${pathPackages} || throw 102
        sudo chmod g+s ${pathPackages} || throw 103
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: Can't change the permissions of path '${pathPackages}'"
            ;;

            101)
                dumpInfoLine "${BRed}Error${RCol}: Can't change the owners of path '${pathPackages}'"
            ;;

            102)
                dumpInfoLine "${BRed}Error${RCol}: Can't change the permanent group of path '${pathPackages}' [#1]"
            ;;

            103)
                dumpInfoLine "${BRed}Error${RCol}: Can't change the permanent group of path '${pathPackages}' [#2]"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error"
            ;;
        esac
        exitScript
    }

    # Move and restart mx-ubuntu if needed
    __moveMxUbuntu
}

# ================================================
# Check & setup the global/share directory
# ================================================
__checkPathPackages() {
    # Check the directory
    if [[ ${cwd} != ${pathMxUbuntu} ]]
    then
        try
        (
            # Check if the target directory exists
            if [ ! -d ${pathPackages} ]
            then
                # Create directory
                dumpInfoLine "Creating directory ${pathPackages}"
                (sudo mkdir -p ${pathPackages}) || throw 100

                # Check again if the target directory exists
                if [ -d ${pathPackages} ]
                then
                    dumpInfoLine "Directory ${pathPackages} created"
                fi
            else
                dumpInfoLine "Directory ${pathPackages} already exists"
            fi
        )
        catch || {
            # There was an error, so show message and exit
            case ${exCode} in
                100)
                    dumpError "Can't create directory ${pathPackages}"
                ;;

                *)
                    dumpError 'Not specified error'
                ;;

            esac
            exitScript;
        }
    fi
}

# ================================================
# Move mx-ubuntu to the global/shared directory
# ================================================
__moveMxUbuntu() {
    # Check the directory
    if [[ ${cwd} != ${pathMxUbuntu} ]]
    then
        # Define the exceptions
        cantMoveDirectory=101
        cantCopyDirectory=102
        cantRestartScript=103

        try
        (
            # Check for development
            if [[ ${isDevelopment} = false || ${cwd} != '/bash-projects/mxframe/mx-ubuntu' ]]
            then
                # Move the directory (is not development)
                dumpInfoLine "Moving directory ${pathMxUbuntu} [${BCya}production${RCol}]"
                #(sudo mv ${cwd} ${pathMxUbuntu}) || throw ${cantMoveDirectory}
                (echo ${sudoPw} | sudo rsync -a \
                    --remove-source-files \
                    --chown=$(whoami):${groupPackages} \
                    --chmod=${permissionPackages} \
                    ${cwd} ${pathPackages}) || throw ${cantCopyDirectory}
            else
                # Copy the directory (is development)
                dumpInfoLine "Copying directory ${pathMxUbuntu} [${BBlu}development${RCol}]"
                #(sudo cp -rp ${cwd} ${pathMxUbuntu}) || throw ${cantCopyDirectory}
                (sudo rsync -a \
                    --chown=$(whoami):${groupPackages} \
                    --chmod=${permissionPackages} \
                    ${cwd} ${pathPackages}) || throw ${cantCopyDirectory}
            fi

            # Call the moved script & exit
            if [[ ${isDevelopment} = false ]]
            then
                dumpInfoLine 'Restarting the script'
                pressKeyToContinue
                cd ${pathMxUbuntu}
                if stringIsEmptyOrNull ${sudoPw}
                then
                    ./start.sh $(getActiveOptionsString) || throw ${cantRestartScript}
                else
                    ./start.sh $(getActiveOptionsString) --sudopw ${sudoPw} || throw ${cantRestartScript}
                fi
                exitScript
            fi
        )
        catch || {
            # There was an error, so show message and exit
            case ${exCode} in
                ${cantMoveDirectory})
                    dumpError "Can't move directory ${cwd} to ${pathMxUbuntu}"
                ;;

                ${cantCopyDirectory})
                    dumpError "Can't copy directory ${cwd} to ${pathMxUbuntu}"
                ;;

                ${cantRestartScript})
                    dumpError "Can't restart ${pathMxUbuntu}/setup.sh"
                ;;

                *)
                    dumpError 'Not specified error'
                ;;

            esac
            exitScript
        }
    fi
}