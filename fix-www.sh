#!/bin/bash

# Never update the project repo
if [[ -d /var/www/html ]]
then
    # Change owner
    sudo chown -R www-data:www-data /var/www/html
#    sudo chgrp -R www-data /var/www/html
    sudo chmod -R 775 /var/www/html
    # https://askubuntu.com/questions/51951/set-default-group-for-user-when-they-create-new-files
    sudo chgrp -R www-data /var/www/html
    sudo chmod -R g+s /var/www/html
#    sudo chown -R $(whoami) /var/www/html
fi
