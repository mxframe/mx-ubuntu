#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to this directory
cd "${pathBash}"

# Never update the project repo
if [[ ${pathBash} != '/bash-projects/mxframe/mx-ubuntu' ]]
then
    # Reset the head
    git reset --hard

    # Pull the new version
    git pull
fi

# Change the permissions
sudo chmod -R 660 . 2>/dev/null
sudo chmod -R 770 *.sh 2>/dev/null
