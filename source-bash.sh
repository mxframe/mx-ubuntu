#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the bash file
if [[ -L /etc/profile.d/mx-ubuntu.bashrc.sh ]]
then
    sudo rm -rf /etc/profile.d/mx-ubuntu.bashrc.sh 2>/dev/null
fi

# Create the symlink
if [[ ${pathBash} = '/bash-projects/mxframe/mx-ubuntu' ]]
then
    sudo ln -s "/bash-projects/mxframe/mx-ubuntu/bashrc.sh" /etc/profile.d/mx-ubuntu.bashrc.sh 2>/dev/null
else
    sudo ln -s "/usr/local/packages/mx-ubuntu/bashrc.sh" /etc/profile.d/mx-ubuntu.bashrc.sh 2>/dev/null
fi

# Source the users bashrc
source ~/.bashrc 2>/dev/null