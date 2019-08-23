#!/bin/bash

# ================================================
# Move the project to another directory
# ================================================
# Check the directory
if [[ ${cwd} != ${pathMxUbuntu} ]]
then
    # Move the directory
    echo ${sudoPw} | sudo mv -R ${cwd} ${pathMxUbuntu}

    # Call the moved script
    bash "${pathMxUbuntu}/setup.sh --sudopw:${sudoPw}"

    # Exit this script
    exit
fi
