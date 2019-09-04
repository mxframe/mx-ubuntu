#!/bin/bash

# ================================================
# Request sudo password
# ================================================
sudoPw=null
showSudoDialog() {
    # Define the labels
    local passwordBoxInfo='Enter your password for sudo:'
    local dialogBackTitle='Your password won´t be stored, but is needed for the installation process.'

    # Check for dialog
    if packageInstalled dialog
    then
        # Ask for password with dialog
        sudoPw=$(dialog --title "${globalDialogTitle}" \
                        --backtitle "${dialogBackTitle}" \
                        --passwordbox "${passwordBoxInfo}" \
                        8 40 3>&1 1>&2 2>&3 3>&-)
    else
        # Ask for password without dialog
        echo -e "${BGre}${dialogTitle}${RCol}"
        while IFS= read -p "${passwordBoxInfo} " -r -s -n 1 char
        do
            if [[ $char == $'\0' ]]
            then
                break
            fi
            prompt='*'
            sudoPw+="$char"
        done
    fi

    # Clear the screen
    clear

    # Check the password
    if stringIsEmptyOrNull ${sudoPw}
    then
        echo -e "${BRed}Canceled by user !!!${RCol}"
        exitScript
    fi

    # Try to activate sudo access
    activateSudo ${sudoPw}

    # Clear the screen
    clear
}