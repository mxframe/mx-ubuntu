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
    if package_installed dialog
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
    if string_is_empty_or_null ${sudoPw}
    then
        echo -e "${BRed}Canceled by user !!!${RCol}"
        exitScript
    fi

    # Activate sudo
    (echo ${sudoPw} | sudo -S ls >/dev/null 2>&1)

    # Clear the screen
    clear
}