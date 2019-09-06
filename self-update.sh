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
find ${pathBash} -type d -exec chmod 770 {} \;
find ${pathBash} -type f -exec chmod 660 {} \;
chmod 770 self-update.sh 2>/dev/null
chmod 770 bashrc.sh 2>/dev/null
chmod 770 start.sh 2>/dev/null
chmod 770 startup.sh 2>/dev/null
