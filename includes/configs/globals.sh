#!/bin/bash

# ================================================
# Define the globals
# ================================================

# Better error log
# From: http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Define the directories
cwd=$('pwd')
pathPackages='/usr/local/packages'
pathMxUbuntu="${pathPackages}/mx-ubuntu"

# Define the packages group and permissions
groupPackages='packages'
permissionPackages=770

# Back title for whiptail
globalLabelBox='MxUbuntu - ServerSetup'