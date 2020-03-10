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
dumpInfoHeader "Clearing the projects cache"
for project in "${!clearCacheProjects[@]}"
do
    # Check if the project exists
    if [[ ! -d "${project}" || ! -f "${project}/artisan" ]]
    then
        dumpErrorLine "The project '${project}' does not exist"
        continue
    fi

    # Dump the info
    dumpInfoLine "Clearing cache of '${project}'"

    # Clear the cache
    php ${project}/artisan cache:clear # >/dev/null 2>&1
    php ${project}/artisan clear-compiled # >/dev/null 2>&1

    # Clear the opcache
    #php artisan opcache:clear >/dev/null 2>&1

    #  Iterate through the nodes
    for node in "${!activeNodes[@]}"
    do
        # Clear the cache data
        if (ssh -t $(whoami)@${nodeServerIps[${node}]} "php ${project}/artisan cache:clear" >/dev/null 2>&1)
        then
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
        else
            dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
        fi

        # Clear the compiled data
        if (ssh -t $(whoami)@${nodeServerIps[${node}]} "php ${project}/artisan clear-compiled" >/dev/null 2>&1)
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

