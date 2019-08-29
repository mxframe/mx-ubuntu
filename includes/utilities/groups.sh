#!/bin/bash

# ================================================
# Get all users
#
# @usage
# declare -A myArray
# ================================================
getAllUsersAndHome() {
    # Define the users
    local -n __users="$1"

    # Use awk to do the heavy lifting.
    # For lines with UID>=1000 (field 3) grab the home directory (field 6)
    local usrInfo=$(awk -F: '{if ($3 >= 1000) print $6}' < /etc/passwd)

    # Use newline as delimiter for for-loop
    IFS=$'\n'
    local userHome
    for userHome in ${usrInfo}
    do
        __users["${userHome##*/}"]="${userHome}"
    done
}
