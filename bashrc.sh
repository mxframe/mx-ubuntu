#!/bin/bash

##############################################################################################################
#
# Collection of bashrc settings / imports.
# This file will be included automatically after setup.
#
##############################################################################################################

# Define the bash path [ NEEDED !!! ]
pathBash="$(dirname "$0")"

# Load the bashrc files
. "${pathBash}/includes/utilities/system.sh"
sourceBashFilesRecursive "${pathBash}/bashrc"
