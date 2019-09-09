#!/bin/bash

# ================================================
# Checkout/update script for git projects
# ================================================

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
[[ ! -f "${pathBash}/config.sh" ]] && cp -rp "${pathBash}/config.example.sh" "${pathBash}/config.sh"
. "${pathBash}/config.sh"

# ================================================
# Define the projects (automatically)
# ================================================
initProjects

# Check the git projects
if [[ ${#projectsTotal[@]} = 0 ]]
then
    dumpError "No git projects found in directory ${pathProjects}"
    exitScript
fi

# Select the projects
showProjectsDialog
if [[ ${updateProjectsCount} = 0 ]]
then
    dumpError "No projects selected"
    exitScript
fi

# Select the specifications
showFrontendBackendUndefinedDialog
if [[ ${updateSpecificationsCount} = 0 ]]
then
    dumpError "No project specifications selected"
    exitScript
fi

# ================================================
# Clear the screen
# ================================================
clearScreen

# ================================================
# Start the updates
# ================================================
updateProjects

# ================================================
# Exit the script
# ================================================
exitScript

