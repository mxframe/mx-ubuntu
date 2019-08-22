#!/bin/bash

##############################################################################################################
#
# Collection of useful functions.
# These functions can be used by any other shell script. Just include this file.
#
##############################################################################################################

# Load the function files
for filename in $HOME/bin/server-setup/functions/*.sh
do
    . ${filename}
done