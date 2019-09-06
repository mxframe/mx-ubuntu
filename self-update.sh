#!/bin/bash

# Define the bash path [ NEEDED !!! ]
pathBash="$(dirname "$0")"

# Change to this directory
cd "${pathBash}"

# Never update the project repo
if [[ ${pathBash} != '/bash-projects/mxframe/mx-ubuntu$' ]]
then
    # Reset the head
    git reset --hard

    # Pull the new version
    git pull
fi

# Change the permissions
sudo chmod -R 440 *
sudo chmod 770 self-update.sh
sudo chmod 770 bashrc.sh
sudo chmod 770 start.sh
sudo chmod 770 startup.sh
