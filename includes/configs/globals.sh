#!/bin/bash

# ================================================
# Define the globals
# ================================================

# Better error log
# From: http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Define the bashPath
# pathBash="$(dirname "$0")"
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Define the directories
cwd=$('pwd')
pathPackages='/usr/local/packages'
pathMxUbuntu="${pathPackages}/mx-ubuntu"
pathProjects="/var/www"

# Define the packages group and permissions
groupPackages='packages'
permissionPackages=770

# Back title for dialog
globalDialogTitle='MxUbuntu - ServerSetup'
globalDialogChecklistInfo="- Use UP/DOWN to navigate through the options\n\
- Press [Space] to de-/select option\n\
- Use LEFT/RIGHT to navigate through the buttons\n\
- Press [Enter] to click the selected button"
