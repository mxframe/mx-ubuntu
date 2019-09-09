#!/bin/bash

##############################################################################################################
#
# Collection of bashrc settings / imports.
# This file will be included automatically after setup.
#
##############################################################################################################

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Check if this is the softlink
if [[ ${pathBash} = '/etc/profile.d' ]]
then
    # Call the original bash script
    file=$(readlink -f "${pathBash}/mx-ubuntu.bashrc.sh")

    # Split path and file
    path=${file%/*}
    file=${file##*/}

    # Change dir
    cd "${path}"
    ./${file}
else
    # Load the bashrc files
    . "${pathBash}/includes/utilities/system.sh"
    sourceBashFilesRecursive "${pathBash}/bashrc"
fi
