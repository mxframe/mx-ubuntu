#!/bin/bash

if [[ ! mountpoint -q /webcluster-share ]]
then
    # Check for package amazon-efs-utils
    if $(dpkg -s 'amazon-efs-utils' >/dev/null 2>&1)
    then
        # Check for package binutils
        sudo apt-get update
        if $(dpkg -s 'binutils' >/dev/null 2>&1)
        then
            sudo apt-get install binutils -y
        fi

        # Install AWS efs utils
        cd /usr/local/packages/
        if [[ ! -d ./efs-utils ]]
        then
            git clone https://github.com/aws/efs-utils
        fi
        cd efs-utils
        ./build-deb.sh
        sudo apt-get install ./build/amazon-efs-utils*deb -y
    fi

	# Make the directory
    if [[ ! -d ./efs-utils ]]
    then
	    sudo mkdir /webcluster-share
    	sudo chown -R www-data:www-data /webcluster-share
	fi

	# Mount the directory
	# sudo mount -t efs fs-2e90a877:/ /webcluster-share
	sudo mount -t efs -o tls fs-2e90a877:/ /webcluster-share
fi

# Change/Fix the permissions
sudo chgroup -R www-data /webcluster-share
sudo chmod -R g+s /webcluster-share
