#!/bin/bash

##############################################################################################################
#
# Collection of project includes.
# This file will be included automatically on execution.
#
##############################################################################################################

# Load the include files
for filename in $HOME/bin/server-setup/includes/*.sh
do
    . ${filename}
done
