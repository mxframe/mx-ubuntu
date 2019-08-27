#!/bin/bash

# ================================================
# Request sudo password
# ================================================
sudoPw=null
showSudoPrompt() {
    # Define the labels
    local labelPrompt='Enter your password for sudo:'
    local labelInfo='Your password won´t be stored, but is needed for the installation process.'

    # Check for dialog
    if packageInstalled dialog
    then
        # Ask for password with dialog
        sudoPw=$(dialog --title "${globalLabelBox}" \
                          --backtitle "${labelInfo}" \
                          --passwordbox "${labelPrompt}" \
                          8 40 3>&1 1>&2 2>&3 3>&-)
    else
        # Ask for password without whiptail
        echo -e "${BGre}${labelInfo}${RCol}"
        while IFS= read -p "${labelPrompt} " -r -s -n 1 char
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