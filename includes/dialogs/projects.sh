#!/bin/bash

# ================================================
# Show the checkboxes dialog for the projects
# ================================================
showProjectsDialog() {
    # Check for dialog
    if ! packageInstalled dialog
    then
        dumpError "The 'dialog' package is not installed"
        exitScript
    fi

    # Define the labels
    local dialogChecklistInfo="\nSelect the projects that you want to update\n\n${globalDialogChecklistInfo}\n "
    local dialogBackTitle='Define the projects and specifications for the updates'

    # Define the options: https://aplicacionesysistemas.com/en/dialog-crear-menus-tus-scripts/
    # With colors: https://wiki.ubuntuusers.de/Howto/Dialog-Optionen/
    local options=()
    local colorFrontend=''
    local colorBackend=''
    local colorUndefined=''
    for project in "${!projectsTotal[@]}"
    do
        # Check for frontend
        if [[ -v projectsFrontend[${project}] ]]
        then
            colorFrontend='\Z0'
        else
            colorFrontend='\Z1'
        fi

        # Check for backend
        if [[ -v projectsBackend[${project}] ]]
        then
            colorBackend='\Z0'
        else
            colorBackend='\Z1'
        fi

        # Check for undefined
        if [[ -v projectsUndefined[${project}] ]]
        then
            colorUndefined='\Z0'
        else
            colorUndefined='\Z1'
        fi

        # Define the option line
        tmpLabel="${colorFrontend}Frontend\Z4 | ${colorBackend}Backend\Z4 | ${colorUndefined}Undefined\Z4"
        options+=("${project}" "${tmpLabel}" off)
    done

    # Show the dialog
    local choices=$(dialog --colors --title 'Projects' \
                     --backtitle "${dialogBackTitle}" \
                     --checklist "${dialogChecklistInfo}" 0 0 0 \
                     "${options[@]}" \
                     3>&1 1>&2 2>&3 3>&-)
                     #2>&1 >/dev/tty)

    # Clear the screen
    clear

    # Check the password
    if stringIsEmptyOrNull ${choices}
    then
        # echo -e "${BRed}Canceled by user !!!${RCol}"
        # exitScript
        return
    fi

    # Set choices as projects to update
    for choice in ${choices}
    do
        # Increase the counter
        (( updateProjectsCount++ ))

        # Remember the choice
        updateProjectsTotal[${choice}]=true
    done
}

# ================================================
# Show the checkboxes dialog for the
# frontend, backend & undefined project-checkouts
# ================================================
showFrontendBackendUndefinedDialog() {
    # Check for dialog
    if ! packageInstalled dialog
    then
        dumpError "The 'dialog' package is not installed"
        exitScript
    fi

    # Iterate through the projects
    for project in "${!updateProjectsTotal[@]}"
    do
        # Define the labels
        local dialogChecklistInfo="\nSpecify the updates for \Z1${project}\Z0\n\n${globalDialogChecklistInfo}\n "
        local dialogBackTitle='Define the projects and specifications for the updates'

        # Define the options
        local options=()

        # Check the frontend
        if [[ -v projectsFrontend[${project}] ]]
        then
            options+=("frontend" "Update the frontend for ${project}" on)
        fi

        # Check the backend
        if [[ -v projectsBackend[${project}] ]]
        then
            options+=("backend" "Update the backend for ${project}" on)
        fi

        # Check undefined
        if [[ -v projectsUndefined[${project}] ]]
        then
            options+=("undefined" "Update ${project}" on)
        fi

        # Show the dialog
        local choices=$(dialog --colors --title "Specifications for ${project}" \
                         --backtitle "${dialogBackTitle}" \
                         --checklist "${dialogChecklistInfo}" 0 0 0 \
                         "${options[@]}" \
                         3>&1 1>&2 2>&3 3>&-)
                         #2>&1 >/dev/tty)

        # Clear the screen
        clear

        # Check the password
        if ! stringIsEmptyOrNull ${choices}
        then
            # Iterate through the choices and remember them
            for choice in ${choices}
            do
                # Increase the counter
                (( updateSpecificationsCount++ ))

                # Remember the choice
                case ${choice} in
                    'frontend')
                        updateProjectsFrontend[${project}]=true
                    ;;

                    'backend')
                        updateProjectsBackend[${project}]=true
                    ;;

                    'undefined')
                        updateProjectsUndefined[${project}]=true
                    ;;
                esac
            done
        fi
    done
}
