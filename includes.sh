#!/bin/bash

##############################################################################################################
#
# Collection of project includes.
# This file will be included automatically on execution.
#
##############################################################################################################

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load the include files
. "${pathBash}/includes/utilities/system.sh"
sourceBashFilesRecursive "${pathBash}/includes"
