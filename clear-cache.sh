#!/bin/bash

# ================================================
# Checkout/update script for git projects
# ================================================

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to this directory
cd "${pathBash}"

# ================================================
# Do some initial stuff
# ================================================
# Clear the screen
clear
# Include the main functionality
. "${pathBash}/includes.sh"

# ================================================
# Include the config
# ================================================
#[[ ! -f "${pathBash}/config.sh" ]] && cp -rp "${pathBash}/config.example.sh" "${pathBash}/config.sh"
. "${pathBash}/config.sh"

## ================================================
## Define the projects (automatically)
## ================================================
#initProjects
#
## Check the git projects
#if [[ ${#projectsTotal[@]} = 0 ]]
#then
#    dumpError "No git projects found in directory ${pathProjects}"
#    exitScript
#fi
#
## Select the projects
#showProjectsDialog
#if [[ ${updateProjectsCount} = 0 ]]
#then
#    dumpError "No projects selected"
#    exitScript
#fi
#
## Select the specifications
#showFrontendBackendUndefinedDialog
#if [[ ${updateSpecificationsCount} = 0 ]]
#then
#    dumpError "No project specifications selected"
#    exitScript
#fi

# ================================================
# Clear the project cache
# ================================================
# Check the git projects
if [[ ${#clearCacheProjects[@]} = 0 ]]
then
    dumpError "No Cache Projects defined"
    exitScript
fi

# ================================================
# Clear the screen
# ================================================
clearScreen

# ================================================
# Get the active nodes
# ================================================
# Dump the info line
dumpInfoHeader "Checking the nodes"

# Checking for the active nodes
declare -g -A activeNodes
for node in "${!nodeServerIps[@]}"
do
    if (nc -w 5 -z "${nodeServerIps[${node}]}" 22)
    then
        dumpInfoLine "Node ${node} [${nodeServerIps[${node}]}] is ${BGre}online${RCol}"
        activeNodes["${node}"]="${nodeServerIps[${node}]}"
    else
        dumpInfoLine "Node ${node} [${nodeServerIps[${node}]}] is ${BRed}offline${RCol}"
    fi
done

# ================================================
# Loop through the users
# ================================================
declare path=''
for name in "${!clearCacheProjects[@]}"
do
    # Define the project path
    path="${clearCacheProjects[${name}]}"

    # Dump the info
    dumpInfoHeader "Clearing cache of '${name}'"

    # Check if the project exists
    if [[ ! -d "${path}" || ! -f "${path}/artisan" ]]
    then
        dumpErrorLine "The project '${name}' does not exist"
        continue
    fi

    # Clear the cache
    php ${path}/artisan cache:clear # >/dev/null 2>&1
    php ${path}/artisan clear-compiled # >/dev/null 2>&1

    # Clear the opcache
    #php artisan opcache:clear >/dev/null 2>&1

    #  Iterate through the nodes
    for node in "${!activeNodes[@]}"
    do
        # Clear the cache data
        dumpInfoHeader "Clearing cache on"
        if (ssh -t $(whoami)@${nodeServerIps[${node}]} "php ${path}/artisan cache:clear" >/dev/null 2>&1)
        then
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
        else
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
        fi

        # Clear the compiled data
        dumpInfoHeader "Clearing compiled scripts on"
        if (ssh -t $(whoami)@${nodeServerIps[${node}]} "php ${path}/artisan clear-compiled" >/dev/null 2>&1)
        then
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
        else
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
        fi
    done
done

# ================================================
# Exit the script
# ================================================
exitScript

