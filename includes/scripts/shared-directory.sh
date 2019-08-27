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
        echo -e "Checking the global directory"

        try
        (
            # Check if the target directory exists
            if [ ! -d ${pathAllBin} ]
            then
                # Create directory
                echo -e "... trying to create directory ${pathAllBin}"
                (echo ${sudoPw} | sudo -S \mkdir -p ${pathAllBin}) || throw ${cantCreateDirectory}
            fi
        )
        catch || {
            # There was an error, so show message and exit
            case ${exCode} in
                ${cantCreateDirectory})
                    echo -e "${BRed}Error${RCol}: Can't create directory ${pathAll}"
                ;;

                *)
                    echo -e "${BRed}Error${RCol}: Not specified error"
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
        echo -e "Moving MxUbuntu to the global directory"

        try
        (
            # Check for development
            if [[ ${isDevelopment} = false || ${cwd} != '/bash-projects/mxframe/mx-ubuntu' ]]
            then
                # Move the directory (is not development)
                echo -e "... trying to move directory ${pathMxUbuntu} [${BCya}development${RCol}]"
                #(echo ${sudoPw} | sudo \mv ${cwd} ${pathMxUbuntu}) || throw ${cantMoveDirectory}
                (echo ${sudoPw} | sudo rsync -a \
                    --remove-source-files \
                    --chown=$(whoami):all \
                    ${cwd} ${pathAllBin}) || throw ${cantCopyDirectory}
            else
                # Copy the directory (is development)
                echo -e "... trying to copy directory ${pathMxUbuntu} [${BGre}development${RCol}]"
                #(echo ${sudoPw} | sudo cp -rp ${cwd} ${pathMxUbuntu}) || throw ${cantCopyDirectory}
                (echo ${sudoPw} | sudo -S rsync -a \
                    --chown=$(whoami):all \
                    ${cwd} ${pathAllBin}) || throw ${cantCopyDirectory}
            fi

            # Call the moved script & exit
            echo -e "... trying to restart the script"
            cd ${pathMxUbuntu}
            ./setup.sh --sudopw:${sudoPw} || throw ${cantRestartScript}
            exitScript
        )
        catch || {
            # There was an error, so show message and exit
            case ${exCode} in
                ${cantMoveDirectory})
                    echo -e "${BRed}Error${RCol}: Can't move directory ${cwd} to ${pathMxUbuntu}"
                ;;

                ${cantCopyDirectory})
                    echo -e "${BRed}Error${RCol}: Can't copy directory ${cwd} to ${pathMxUbuntu}"
                ;;

                ${cantRestartScript})
                    echo -e "${BRed}Error${RCol}: Can't restart ${pathMxUbuntu}/setup.sh"
                ;;

                *)
                    echo -e "${BRed}Error${RCol}: Not specified error"
                ;;

            esac
            exitScript
        }
    fi
}