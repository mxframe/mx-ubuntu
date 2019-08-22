#!/bin/bash

# ================================================
# Request sudo password
# ================================================
# Check for dialog
labelPrompt='Enter your password for sudo:'
labelInfo='Your password won´t be stored, but is needed for the installation process.'
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
# Check the password
if string_is_empty_or_null ${sudoPw}
then
    echo -e "${BRed}Canceled by user !!!${RCol}"
    exit
fi
