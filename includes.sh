#!/bin/bash

##############################################################################################################
#
# Collection of project includes.
# This file will be included automatically on execution.
#
##############################################################################################################

# Define the bash path [ NEEDED !!! ]
pathBash="$(dirname "$0")"

# Load the include files
. "${pathBash}/includes/utilities/system.sh"
sourceBashFilesRecursive "${pathBash}/includes"
