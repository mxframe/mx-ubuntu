#!/bin/bash

# ================================================
# Check if a package is installed
#
# @usage
# packageInstalled PACKAGE_NAME || echo 'not installed'
# ================================================
packageInstalled() {
    if ! $(dpkg -s $1 >/dev/null 2>&1)
    then
        # Return false
        return 1
    fi

    # Return true
    return 0
}

# ================================================
# Source/include/load files
#
# @usage
# sourceBashFiles ${path}
# ================================================
sourceBashFiles() {
    local directory=$1

    # Check if it is empty
    local -r response="${directory}"
    if [[ -z "${response}" || "${response}" == "null" ]]
    then
        return
    fi

    # Iterate trough the files
    shopt -s nullglob
    for filename in ${directory}/*.sh
    do
        . ${filename}
    done
}

# ================================================
# Source/include/load files recursive
#
# @usage
# sourceBashFilesRecursive ${path}
# ================================================
sourceBashFilesRecursive() {
    local directory=$1

    # Check if it is empty
    local -r response="${directory}"
    if [[ -z "${response}" || "${response}" == "null" ]]
    then
        return
    fi

    # Iterate trough the files
    local filename
    shopt -s nullglob
    for filename in ${directory}/*.sh
    do
        . ${filename}
    done

    # Iterate trough the directories
    local dir
    shopt -s nullglob
    for dir in `find ${directory} -mindepth 1 -type d`
    do
        sourceBashFilesRecursive ${dir}
    done
}

# ================================================
# Check if a file or directory exists
#
# @usage
# if [[ $(fileOrDirectoryExists /tmp/tmp_file) = true ]]; then ...
# ================================================
fileOrDirectoryExists() {
    if [[ -f $1 ]] || [[ -d $1 ]]
    then
        echo true
    else
        echo false
    fi
}

# ================================================
# Turn off enforcing
#
# @usage
# turnOffEnforcing
# ================================================
turnOffEnforcing() {
    if [[ `getenforce 2>/dev/null` = 'Enforcing' ]]
    then
        sudo setenforce 0
    fi
}

# ================================================
# Turn off selinux
#
# @usage
# turnOffSelinux
# ================================================
turnOffSelinux() {
    if [[ -f /etc/sysconfig/selinux ]]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        echo 'SELINUX=disabled' > /etc/sysconfig/selinux
        echo 'SELINUXTYPE=targeted' >> /etc/sysconfig/selinux
        sudo chmod -f 0640 /etc/sysconfig/selinux
    fi
}

# ================================================
# Turn on selinux
#
# @usage
# turnOnSelinux
# ================================================
SELINUX=`grep ^SELINUX= /etc/selinux/config 2>/dev/null | awk -F'=' '{ print $2 }'` ||
turnOnSelinux() {
    if [[ $SELINUX = enforcing || $SELINUX = permissive ]]; then
        setenforce 1
    fi
}

# ================================================
# Get all users
#
# @usage
# declare -A myArray
# getAllUsers myArray
#
# https://unix.stackexchange.com/questions/462068/bash-return-an-associative-array-from-a-function-and-then-pass-that-associative
# https://www.linuxjournal.com/content/return-values-bash-functions
# https://unix.stackexchange.com/questions/199220/how-to-loop-over-users
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

# ================================================
# Update & upgrade the server
#
# @usage
# updateAndUpgrade
#
# @info
# Dumps info lines
# ================================================
declare -g updatedAndUpgraded=false
updateAndUpgrade() {
    if [[ ${updatedAndUpgraded} != true ]]
    then
        updatedAndUpgraded=true
        dumpInfoLine 'Update and upgrade the server'
        dumpInfoLine 'Updating the server'
        sudo apt-get -q -qq update -y 2>/dev/null
        dumpInfoLine 'Upgrading the server'
        sudo apt-get -q -qq upgrade -y 2>/dev/null
        dumpInfoLine "... ${BGre}done${RCol}"
    fi
}

# ================================================
# Update & upgrade the server
#
# @usage
# updateAndUpgrade
#
# @info
# Dumps info lines
# ================================================
installDialog() {
    dumpInfoLine 'Install dialog'
    package_installed dialog || sudo apt-get -q -qq install dialog -y 2>/dev/null
    dumpInfoLine "... ${BGre}done${RCol}"
}
