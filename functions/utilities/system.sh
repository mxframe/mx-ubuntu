#!/bin/bash

# ================================================
# Check if a package is installed
#
# @usage
# package_installed PACKAGE_NAME || echo 'not installed'
# ================================================
function package_installed() {
    if ! $(dpkg -s $1 >/dev/null 2>&1)
    then
        return 1
    fi
    return 0
}

# ================================================
# Source/include/load files
#
# @usage
# source_bash_files ${path}
# ================================================
function source_bash_files() {
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
# source_bash_files_recursive ${path}
# ================================================
function source_bash_files_recursive() {
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
        source_bash_files_recursive ${dir}
    done
}