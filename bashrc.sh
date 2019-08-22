#!/bin/bash

##############################################################################################################
#
# Collection of bashrc settings / imports.
# This file will be included automatically after setup.
#
##############################################################################################################

# Load the bashrc files
for filename in $HOME/bin/server-setup/bashrc/*.sh
do
    . ${filename}
done
