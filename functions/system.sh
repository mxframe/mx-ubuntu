#!/bin/bash

# ================================================
# Check if a package is installed
#
# @usage
# package_installed PACKAGE_NAME || echo 'not installed'
# ================================================
package_installed() {
    if ! $(dpkg -s $1 >/dev/null 2>&1)
    then
        return 1
    fi
    return 0
}

# ================================================
# Include/load files recursive
#
# @usage
# package_installed PACKAGE_NAME || echo 'not installed'
# ================================================
include_files_recursive() {
    local directory=$1

    # Check if it is empty
    local -r response="${directory}"
    if [[ -z "${response}" || "${response}" == "null" ]]
    then
        return
    fi

    # Iterate trough the files
    for filename in ${directory}/*.sh
    do
        . ${filename}
    done

    # Iterate trough the directories
    for dir in `find ${directory} -type d`
    do
        include_files_recursive ${directory}
    done
}