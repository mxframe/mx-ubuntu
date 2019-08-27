#!/bin/bash

# ================================================
# Check & setup the global/share directory
# ================================================
checkPathAll() {
    # Check the directory
    if [[ ${cwd} != ${pathMxUbuntu} ]]
    then
        # Define the exceptions
        cantCreateDirectory=100

        # Print the message
        dumpInfoHeader "Checking the global directory"

        try
        (
            # Check if the target directory exists
            if [ ! -d ${pathAllBin} ]
            then
                # Create directory
                dumpInfoLine "Creating directory ${pathAllBin}"
                (sudo \mkdir -p ${pathAllBin}) || throw ${cantCreateDirectory}

                # Check again if the target directory exists
                if [ -d ${pathAllBin} ]
                then
                    dumpInfoLine "Directory ${pathAllBin} created"
                fi
            else
                dumpInfoLine "Directory ${pathAllBin} already exists"
            fi
        )
        catch || {
            # There was an error, so show message and exit
            case ${exCode} in
                ${cantCreateDirectory})
                    dumpError "Can't create directory ${pathAll}"
                ;;

                *)
                    dumpError "Not specified error"
                ;;

            esac
            exitScript;
        }
    fi
}

# ================================================
# Move mx-ubuntu to the global/shared directory
# ================================================
moveMxUbuntu() {
    # Check the directory
    if [[ ${cwd} != ${pathMxUbuntu} ]]
    then
        # Define the exceptions
        cantMoveDirectory=101
        cantCopyDirectory=102
        cantRestartScript=103

        # Print the message
        dumpInfoHeader "Moving MxUbuntu to the global directory"

        try
        (
            # Check for development
            if [[ ${isDevelopment} = false || ${cwd} != '/bash-projects/mxframe/mx-ubuntu' ]]
            then
                # Move the directory (is not development)
                dumpInfoLine "Moving directory ${pathMxUbuntu} [${BCya}development${RCol}]"
                #(sudo \mv ${cwd} ${pathMxUbuntu}) || throw ${cantMoveDirectory}
                (echo ${sudoPw} | sudo rsync -a \
                    --remove-source-files \
                    --chown=$(whoami):all \
                    ${cwd} ${pathAllBin}) || throw ${cantCopyDirectory}
            else
                # Copy the directory (is development)
                dumpInfoLine "Copying directory ${pathMxUbuntu} [${BGre}development${RCol}]"
                #(sudo \cp -rp ${cwd} ${pathMxUbuntu}) || throw ${cantCopyDirectory}
                (sudo rsync -a \
                    --chown=$(whoami):all \
                    ${cwd} ${pathAllBin}) || throw ${cantCopyDirectory}
            fi

            # Call the moved script & exit
            dumpInfoLine "Restarting the script"
            cd ${pathMxUbuntu}
            exitScript
            if stringIsEmptyOrNull ${sudoPw}
            then
                ./setup.sh || throw ${cantRestartScript}
            else
                ./setup.sh --sudopw ${sudoPw} || throw ${cantRestartScript}
            fi
            exitScript
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
                    dumpError "Not specified error"
                ;;

            esac
            exitScript
        }
    fi
}