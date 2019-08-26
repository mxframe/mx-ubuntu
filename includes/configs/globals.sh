#!/bin/bash

# ================================================
# Define the globals
# ================================================

# Better error log
# From: http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Define the directories
cwd=$('pwd')
pathAll='/home/all'
pathAllBin="${pathAll}/bin"
pathMxUbuntu="${pathAllBin}/mx-ubuntu"

# Back title for whiptail
globalLabelBox='MxUbuntu - ServerSetup'