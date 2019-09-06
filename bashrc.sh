#!/bin/bash

##############################################################################################################
#
# Collection of bashrc settings / imports.
# This file will be included automatically after setup.
#
##############################################################################################################

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load the bashrc files
. "${pathBash}/includes/utilities/system.sh"
sourceBashFilesRecursive "${pathBash}/bashrc"
