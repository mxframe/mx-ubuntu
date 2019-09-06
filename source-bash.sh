#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the bash file
if [[ -L /etc/profile.d/mx-ubuntu.bashrc ]]
then
    rm -rf /etc/profile.d/mx-ubuntu.bashrc 2>/dev/null
fi

# Create the symlink
if [[ ${pathBash} = '/bash-projects/mxframe/mx-ubuntu' ]]
then
    ln -s "/bash-projects/mxframe/mx-ubuntu/bashrc.sh" /etc/profile.d/mx-ubuntu.bashrc 2>/dev/null
else
    ln -s "/usr/local/packages/mx-ubuntu/bashrc.sh" /etc/profile.d/mx-ubuntu.bashrc 2>/dev/null
fi

# Source the users bashrc
source ~/.bashrc 2>/dev/null