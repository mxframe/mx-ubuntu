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
# fileOrDirectoryExists ${path}
# ================================================
fileOrDirectoryExists() {
    [[ -f $1 ]] || [[ -d $1 ]]
}