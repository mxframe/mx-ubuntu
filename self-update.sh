#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to this directory
cd "${pathBash}"

# Never update the project repo
if [[ ${pathBash} != '/bash-projects/mxframe/mx-ubuntu' ]]
then
    # Reset the head
    git reset --hard 2>/dev/null

    # Pull the new version
    git pull 2>/dev/null
fi

# Change the permissions
find ${pathBash} -type d -exec chmod 770 {} \; 2>/dev/null
find ${pathBash} -type f -exec chmod 660 {} \; 2>/dev/null
chmod 770 self-update.sh 2>/dev/null
chmod 770 bashrc.sh 2>/dev/null
chmod 770 checkout.sh 2>/dev/null
chmod 770 start.sh 2>/dev/null
chmod 770 startup.sh 2>/dev/null
chmod 770 source-bash.sh 2>/dev/null
