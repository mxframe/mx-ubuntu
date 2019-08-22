#!/bin/bash

# ================================================
# Check if a package is installed
#
# @usage
# package_installed PACKAGE_NAME || echo 'not installed'
# ================================================
package_installed () {
    if ! $(dpkg -s $1 >/dev/null 2>&1)
    then
        return 1
    fi
    return 0
}
