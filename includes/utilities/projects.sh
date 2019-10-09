#!/bin/bash

# ================================================
# Init the projects
# ================================================
declare -g -A projectsFrontend
declare -g -A projectsBackend
declare -g -A projectsUndefined
declare -g -A projectsTotal
declare -g projectsCount=0
initProjects() {
    # Dump the info line
    dumpInfoHeader 'Initialising the projects'

    # Search for the git projects
    local gitProjects=( $(findGitProjects ${pathProjects}) )

    # Iterate through the git projects
    dumpInfoLine 'Scanning for project types'
    for project in "${gitProjects[@]}"
    do
        # Dump the info line
        dumpInfoLine "... in ${project}"

        # Increase the counter
        projectsCount=$((projectsCount+1))

        # Split path and repo
        #path=${project%/*}
        repo=${project##*/}

        # Lower the repo
        lowered=${repo,,}

        if [[ ${lowered:(-8)} = 'frontend' ]]
        then
            # Define the repo specification
            repoSpecification='frontend'

            # Define the repo key
            repoKey=${repo:0:(-9)}
            repoKey=${repoKey,,}

            # Set repo in undefined projects array
            projectsFrontend[${repoKey}]=${project}
        elif [[ ${lowered:(-7)} = 'backend' ]]
        then
            # Define the repo specification
            repoSpecification='backend'

            # Define the repo key
            repoKey=${repo:0:(-8)}
            repoKey=${repoKey,,}

            # Set repo in undefined projects array
            projectsBackend[${repoKey}]=${project}
        else
            # Define the repo specification
            repoSpecification='undefined'

            # Define the repo key
            repoKey=${repo,,}

            # Set repo in undefined projects array
            projectsUndefined[${repoKey}]=${project}
        fi

        # Set repo in total projects array
        projectsTotal[${repoKey}]=true
    done

#    echo ''
#    echo -e "${BYel}Projects are${RCol}:"
#    for x in "${!projectsTotal[@]}"
#    do
#        printf " ${BGre}>${RCol} [${BWhi}%s${RCol}]=%s\n" "$x" "${projectsTotal[$x]}"
#    done
#    exitScript
}

# ================================================
# Update the projects
# ================================================
declare -g rolloutServerIP
declare -g -A nodeServerIps
declare -g -A updateProjectsFrontend
declare -g -A updateProjectsBackend
declare -g -A updateProjectsUndefined
declare -g -A updateProjectsTotal
declare -g updateProjectsCount=0
declare -g updateSpecificationsCount=0
declare -g composerLockFileTime=0
declare -g packageJsonFileTime=0
declare -g packageLockJsonFileTime=0
updateProjects() {
    # Check the projects
    if [[ ${updateProjectsCount} = 0 ]]
    then
        dumpError "No projects selected"
        exitScript
    fi

    # Check the project specifications
    if [[ ${updateSpecificationsCount} = 0 ]]
    then
        dumpError "No project specifications selected"
        exitScript
    fi

    # Dump the disk space
    freediskspace=$(($(df -P "/var/www/html" | awk 'NR == 1 {next} {print $4}')/1000000))
    dumpInfoHeader "${BGre}Free Disk-Space for /var/www/html:${RCol} ${freediskspace} GB"
    dumpInfoLine "$(date)"

    # Check the IPs
    dumpInfoHeader "Checking the IPs"
    dnsIp=$(dig +short spectrum8-rollout-balancer-941038166.eu-central-1.elb.amazonaws.com | sort -n | nawk '{print $1; exit}')
    #dnsIp=${tmpIP}
    dumpInfoLine "DNS-IP: ${dnsIp}"
    hostsIP=$(ping -c 1 "${rolloutTestUrl}" -w 3 | gawk -F'[()]' '/PING/{print $2}')
    dumpInfoLine "Hosts-IP: ${hostsIP}"
    if [[ ${dnsIp} != ${hostsIP} ]]
    then
        dumpInfoLine "Trying to fix /etc/hosts entries"
        sudo sed -i "s/${hostsIP}/${dnsIp}/g" /etc/hosts
        hostsIP=$(ping -c 1 "${rolloutTestUrl}" -w 3 | gawk -F'[()]' '/PING/{print $2}')
        dumpInfoLine "New Hosts-IP: ${hostsIP}"
        if [[ ${dnsIp} != ${hostsIP} ]]
        then
            dumpInfoLine "... ${BRed}error${RCol}: can't fix the IP"
            exitScript
        fi
    fi

    # Define the backup date
    local backupDate=$(date '+%Y-%m-%d_%H:%M:%S')

    # Iterate through the projects to update
    for project in "${!updateProjectsTotal[@]}"
    do
        # Dump the info header
        dumpInfoHeader "Updating ${project}"

        # Check the backend [needs to be first]
        if [[ -v updateProjectsBackend[${project}] ]]
        then
            updateBackendProject "${project}" "${backupDate}"
        fi
    done

    # Iterate through the projects to update
    for project in "${!updateProjectsTotal[@]}"
    do
        # Check the undefined [needs to be second]
        if [[ -v updateProjectsUndefined[${project}] ]]
        then
            updateUndefinedProject "${project}" "${backupDate}"
        fi
    done

    # Iterate through the projects to update
    for project in "${!updateProjectsTotal[@]}"
    do
        # Check the frontend [needs to be third]
        if [[ -v updateProjectsFrontend[${project}] ]]
        then
            updateFrontendProject "${project}" "${backupDate}"
        fi
    done

    # Iterate through the projects to clear the cache
    for project in "${!updateProjectsTotal[@]}"
    do
        # Check the frontend [needs to be third]
        if [[ -v updateProjectsBackend[${project}] ]]
        then
            clearBackendCache "${project}"
        fi
    done

    # Dump the info line
    dumpInfoHeader "Checking the nodes"

    # Checking for the active nodes
    local -g -A activeNodes
    for node in "${!nodeServerIps[@]}"
    do
        if (nc -w 5 -z "${nodeServerIps[${node}]}" 22)
        then
            dumpInfoLine "Node ${node} [${nodeServerIps[${node}]}] is ${BGre}online${RCol}"
            activeNodes["${node}"]="${nodeServerIps[${node}]}"
        else
            dumpInfoLine "Node ${node} [${nodeServerIps[${node}]}] is ${BRed}offline${RCol}"
        fi
    done

    # Asc for sync
    dumpInfoHeader "Should the folders be synced with the nodes?"
    printf " ${BBlu}>${RCol} ${BYel}Rsync?${RCol} [J/n]"
    read -p ": " answer
    if [ "${answer,,}" = "n" ]
	then
	    exitScript
	fi


#    # Check for a default index.htm
#    if [[ -f /var/www/html/index.html ]]
#    then
#        # Dump the info line
#        dumpInfoHeader "Rsyncing /var/www/html/index.html"
#
#        for node in "${!activeNodes[@]}"
#        do
#            if (rsync -aze ssh "/var/www/html/index.html" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" >/dev/null 2>&1)
#            then
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: file ${BGre}synced${RCol}"
#            else
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: file ${BRed}not synced${RCol}"
#            fi
#        done
#
#        # Dump the info line & change the owner
#        dumpInfoHeader "Chown /var/www/html/index.html"
#        for node in "${!activeNodes[@]}"
#        do
#            if (ssh -t $(whoami)@${nodeServerIps[${node}]} 'sudo chown -R www-data:www-data /var/www/html/index.html' >/dev/null 2>&1)
#            then
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
#            else
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
#            fi
#        done
#    fi
#
#    # Check for a default folder
#    if [[ -d /var/www/html/default ]]
#    then
#        # Dump the info line
#        dumpInfoHeader "Rsyncing /var/www/html/default"
#
#        for node in "${!activeNodes[@]}"
#        do
#            if (rsync -aze ssh "/var/www/html/default" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
#            then
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: folder ${BGre}synced${RCol}"
#            else
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: folder ${BRed}not synced${RCol}"
#            fi
#        done
#
#        # Dump the info line & change the owner
#        dumpInfoHeader "Chown /var/www/html/default"
#        for node in "${!activeNodes[@]}"
#        do
#            if (ssh -t $(whoami)@${nodeServerIps[${node}]} 'sudo chown -R www-data:www-data /var/www/html/default' >/dev/null 2>&1)
#            then
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
#            else
#                dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
#            fi
#        done
#    fi

    # Iterate through the projects and rsync the folders
    if [[ ${isMasterServer} = true ]]
    then
        for project in "${!updateProjectsTotal[@]}"
        do
            # Dump the info line
            dumpInfoHeader "Rsyncing the servers for ${project}"

            for node in "${!activeNodes[@]}"
            do
                # Check the backend [needs to be first]
                # @todombe exclude sessions & cache or complete storage
                if [[ -v updateProjectsBackend[${project}] ]]
                then
                    #echo ${projectsBackend[${project}]}
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R $(whoami):www-data ${projectsBackend[${project}]}" >/dev/null 2>&1
#                    if (rsync -aze ssh "${projectsBackend[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    if (rsync -rlpgoD -ze ssh "${projectsBackend[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    then
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: backend ${BGre}synced${RCol}"
                    else
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: backend ${BRed}not synced${RCol}"
                    fi

#                    # Dump the info line & change the owner
#                    dumpInfoHeader "Chown ${projectsBackend[${project}]}"
#                    if (ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsBackend[${project}]}" >/dev/null 2>&1)
#                    then
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
#                    else
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
#                    fi
                    dumpInfoLine "... ... chown -R www-data:www-data ${projectsBackend[${project}]}"
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsBackend[${project}]}" >/dev/null 2>&1
                fi

                # Check the undefined [needs to be second]
                if [[ -v updateProjectsUndefined[${project}] ]]
                then
                    #echo ${projectsUndefined[${project}]}
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R $(whoami):www-data ${projectsUndefined[${project}]}" >/dev/null 2>&1
#                    if (rsync -aze ssh "${projectsUndefined[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    if (rsync -rlpgoD -ze ssh "${projectsUndefined[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    then
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: undefined ${BGre}synced${RCol}"
                    else
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: undefined ${BRed}not synced${RCol}"
                    fi

#                    # Dump the info line & change the owner
#                    dumpInfoHeader "Chown ${projectsUndefined[${project}]}"
#                    if (ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsUndefined[${project}]}" >/dev/null 2>&1)
#                    then
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
#                    else
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
#                    fi
                    dumpInfoLine "... ... chown -R www-data:www-data ${projectsUndefined[${project}]}"
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsUndefined[${project}]}" >/dev/null 2>&1
                fi

                # Check the backend [needs to be third]
                if [[ -v updateProjectsFrontend[${project}] ]]
                then
                    #echo ${projectsFrontend[${project}]}
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R $(whoami):www-data ${projectsFrontend[${project}]}" >/dev/null 2>&1
#                    if (rsync -aze ssh "${projectsFrontend[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    if (rsync -rlpgoD -ze ssh "${projectsFrontend[${project}]}" $(whoami)@${nodeServerIps[${node}]}:"/var/www/html" --delete >/dev/null 2>&1)
                    then
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: frontend ${BGre}synced${RCol}"
                    else
                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: frontend ${BRed}not synced${RCol}"
                    fi

#                    # Dump the info line & change the owner
#                    dumpInfoHeader "Chown ${projectsFrontend[${project}]}"
#                    if (ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsFrontend[${project}]}" >/dev/null 2>&1)
#                    then
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BGre}done${RCol}"
#                    else
#                        dumpInfoLine "... Node ${node} [${nodeServerIps[${node}]}]: ${BRed}error${RCol}"
#                    fi
                    dumpInfoLine "... ... chown -R www-data:www-data ${projectsFrontend[${project}]}"
                    ssh -t $(whoami)@${nodeServerIps[${node}]} "sudo chown -R www-data:www-data ${projectsFrontend[${project}]}" >/dev/null 2>&1
                fi
            done
        done
    fi

    # Fix the git permissions
    # They are broken after each pull
    chmod 660 "${pathPackages}/.git/.git-credentials" >/dev/null 2>&1
    chown -R $(whoami):packages "${pathPackages}/.git" >/dev/null 2>&1

    # Rsync
    #rsync -aze ssh /var/www/html/ $(whoami)@172.31.3.155:/var/www/html/ --delete
}

projectBackup() {
    # Define the path
    local path=${1:-}

    # Define backup date
    local backupDate=${2:-$(date '+%Y-%m-%d_%H:%M')}

    # Dump the info line
    dumpInfoLine "... making a backup"

#    # Split path and repo
#    repo=${path##*/}
#    path=${path%/*}

    # Define the backup path
    needle='/var/www/'
    pathBackups="/var/www/backups/"
    backupPath="${path/${needle}/${pathBackups}}"

    # Check if the backup path exists
    if [[ ! -d ${pathBackups} ]]
    then
        mkdir ${pathBackups} >/dev/null 2>&1
    fi

    # Check if the backup path exists
    if [[ ! -d ${pathBackups} ]]
    then
        dumpInfoLine "... ... ${BRed}error${RCol} (${pathBackups} does not exist)"
        return
    fi

    # Check if the backup path exists
    if [[ ! -d ${backupPath} ]]
    then
        mkdir -p ${backupPath} >/dev/null 2>&1
        if [[ ! -d ${backupPath} ]]
        then
            dumpInfoLine "... ... ${BRed}error${RCol} (${backupPath} does not exist)"
            return
        fi
    fi

    # Backup the project
    try
    (
        #cp -rp "${path}" "${backupPath}/${backupDate}" >/dev/null 2>&1 || throw 100
        if [[ ! -d "${backupPath}/${backupDate}" ]]
        then
            rsync -a "${path}" "${backupPath}/${backupDate}" >/dev/null 2>&1 || throw 100
        fi
    )
    catch || {
        dumpInfoLine "... ... ${BRed}error${RCol} (unknown)"
        return
    }

    # Dump the info line
    dumpInfoLine "... ... ${BGre}done${RCol}"

    # Dump the info line
    dumpInfoLine "... removing older backups"

    # Remove the oldest folders (expect 5)
    cd ${backupPath} && rm -rf `ls -t | tail -n +6` >/dev/null 2>&1

    # Dump the info line
    dumpInfoLine "... ... ${BGre}done${RCol}"
}

updateBackendProject () {
    # Dump the info line
    dumpInfoLine 'Backend'

    # Define the project name
    local projectName=${1:-}

    # Check the project name
    try
    (
        if [[ ${projectName} = '' ]] || [[ ! -v projectsBackend[${projectName}] ]]
        then
            dumpInfoLine "... ${BRed}error${RCol} (undefined project)"
            return
        fi
    )
    catch || {
        dumpInfoLine "... ${BRed}error${RCol} (unknown)"
        return
    }

    # Check if the directory exists
    if [[ ! -d ${projectsBackend[${projectName}]} ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (directory does not exist)"
        return
    fi

    # Backup the folder
    projectBackup "${projectsBackend[${projectName}]}"

    # Perform the git pull
    projectGitPull "${projectsBackend[${projectName}]}"

    # Make the composer update
    projectComposerUpdate "${projectsBackend[${projectName}]}"

    # Make the npm update
    projectNpmInstallAndGenerate "${projectsBackend[${projectName}]}"
}

updateUndefinedProject () {
    # Dump the info line
    dumpInfoLine 'Undefined'

    # Define the project name
    local projectName=${1:-}

    # Check the project name
    try
    (
        if [[ ${projectName} = '' ]] || [[ ! -v projectsUndefined[${projectName}] ]]
        then
            dumpInfoLine "... ${BRed}error${RCol} (undefined project)"
            return
        fi
    )
    catch || {
        dumpInfoLine "... ${BRed}error${RCol} (unknown)"
        return
    }

    # Check if the directory exists
    if [[ ! -d ${projectsUndefined[${projectName}]} ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (directory does not exist)"
        return
    fi

    # Backup the folder
    projectBackup "${projectsUndefined[${projectName}]}"

    # Perform the git pull
    projectGitPull "${projectsUndefined[${projectName}]}"

    # Make the composer update
    projectComposerUpdate "${projectsUndefined[${projectName}]}"

    # Make the npm update
    projectNpmInstallAndGenerate "${projectsUndefined[${projectName}]}"
}

updateFrontendProject () {
    # Dump the info line
    dumpInfoLine 'Frontend'

    # Define the project name
    local projectName=${1:-}

    # Check the project name
    try
    (
        if [[ ${projectName} = '' ]] || [[ ! -v projectsFrontend[${projectName}] ]]
        then
            dumpInfoLine "... ${BRed}error${RCol} (undefined project)"
            return
        fi
    )
    catch || {
        dumpInfoLine "... ${BRed}error${RCol} (unknown)"
        return
    }

    # Check if the directory exists
    if [[ ! -d ${projectsFrontend[${projectName}]} ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (directory does not exist)"
        return
    fi

    # Backup the folder
    projectBackup "${projectsFrontend[${projectName}]}"

    # Perform the git pull
    projectGitPull "${projectsFrontend[${projectName}]}"

    # Make the composer update
    projectComposerUpdate "${projectsFrontend[${projectName}]}"

    # Make the npm update
    projectNpmInstallAndGenerate "${projectsFrontend[${projectName}]}"
}

clearBackendCache () {
    # Dump the info line
    dumpInfoLine 'Clearing backend cache'

    # Define the project name
    local projectName=${1:-}

    # Check the project name
    try
    (
        if [[ ${projectName} = '' ]] || [[ ! -v projectsBackend[${projectName}] ]]
        then
            dumpInfoLine "... ${BRed}error${RCol} (undefined project)"
            return
        fi
    )
    catch || {
        dumpInfoLine "... ${BRed}error${RCol} (unknown)"
        return
    }

    # Check if the directory exists
    local path="${projectsBackend[${projectName}]}"
    if [[ ! -d ${path} ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (directory does not exist)"
        return
    fi

    # Change the directory
    cd ${path}

    # Check if a artisan file exists
    if [[ ! -f "${path}/artisan" ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (no artisan file)"
    else
        # Clear the cache
        php artisan cache:clear >/dev/null 2>&1
    fi

    # Check if a cache data directory exists
    if [[ ! -d "${path}/storage/framework/cache/data/" ]]
    then
        dumpInfoLine "... ${BRed}error${RCol} (no cache directory)"
    else
        # Clear the cache
        if hasSudo
        then
            sudo rm -R ${path}/storage/framework/cache/data/* >/dev/null 2>&1
        fi
    fi

    # Dump the info line
    dumpInfoLine "... ${BGre}done${RCol}"
}

projectGitPull() {
    # Define the path
    local path=${1:-}

    # Check if a git file exists
    if [[ ! -d "${path}/.git" ]]
    then
        return
    fi

    # Remember the file times
    if [[ -f "${path}/composer.lock" ]]
    then
        composerLockFileTime=$(stat -c '%Y' "${path}/composer.lock")
    fi
    if [[ -f "${path}/package.json" ]]
    then
        packageJsonFileTime=$(stat -c '%Y' "${path}/package.json")
    fi
    if [[ -f "${path}/package-lock.json" ]]
    then
        packageLockJsonFileTime=$(stat -c '%Y' "${path}/package-lock.json")
    fi

    # Change the directory
    cd ${path}

    # Dump the info line
    dumpInfoLine "... git pull"

    # Reset the repo
    # https://stackoverflow.com/questions/24983762/git-ignore-local-file-changes/24983863
    # git reset --hard >/dev/null 2>&1
    git reset --hard

    # Make a git pull
    # git pull >/dev/null 2>&1
    git pull

    # Fix the git permissions
    # They are broken after each pull
    chmod 660 "${pathPackages}/.git/.git-credentials" >/dev/null 2>&1
    chown -R $(whoami):packages "${pathPackages}/.git" >/dev/null 2>&1

    # Dump the info line
    dumpInfoLine "... ... ${BGre}done${RCol}"
}

projectComposerUpdate() {
    # Define the path
    local path=${1:-}

    # Check if a composer file exists
    if [[ ! -f "${path}/composer.json" ]]
    then
        return
    fi

    # Change the directory
    cd ${path}

    # Check the file time
#    if [[ -f "${path}/composer.lock" ]] && [[ ${composerLockFileTime} = $(stat -c '%Y' "${path}/composer.lock") ]]
#    then
#        dumpInfoLine "... composer install"
#        dumpInfoLine "... ... ${BYel}not needed${RCol}"
#        return
#    fi

    # Check for composer.lock
#    if [[ -f "${path}/composer.lock" ]]
#    then
#        # Dump the info line
#        dumpInfoLine "... composer install"
#
#        # Install
#        #composer install >/dev/null 2>&1
#        composer install
#    else
        # Always update, because of local repos/paths
        # Dump the info line
        dumpInfoLine "... composer update"

        # Update
        #composer update >/dev/null 2>&1
        composer update
#    fi

    # Clear the cache
    php artisan cache:clear >/dev/null 2>&1

    # Dump the info line
    dumpInfoLine "... ... ${BGre}done${RCol}"
}

projectNpmInstallAndGenerate() {
    # Define the path
    local path=${1:-}

    # Check if a package file exists
    #if [[ ! -f "${path}/package.json" ]]
    if [[ ! -f "${path}/package-lock.json" ]]
    then
        return
    fi

    # Change the directory
    cd ${path}

    # Check the file time
    #if [[ -d "${path}/node_modules" ]] && [[ -f "${path}/package.json" ]] && [[ ${packageJsonFileTime} = $(stat -c '%Y' "${path}/package.json") ]]
    if [[ -d "${path}/node_modules" ]] && [[ -f "${path}/package-lock.json" ]] && [[ ${packageLockJsonFileTime} = $(stat -c '%Y' "${path}/package-lock.json") ]]
    then
        dumpInfoLine "... npm install"
        dumpInfoLine "... ... ${BYel}not needed${RCol}"
    else
        # Dump the info line
        dumpInfoLine "... npm install"

        # Install
        #npm install >/dev/null 2>&
        npm audit fix
        npm install

        # Dump the info line
        dumpInfoLine "... ... ${BGre}done${RCol}"
    fi

    # Check if a nuxt file exists
    if [[ ! -f "${path}/nuxt.config.js" ]]
    then
        return
    fi

    # Check if a .env & .env.example exists
    if [[ ! -f "${path}/.env" ]] && [[ -f "${path}/.env.example" ]]
    then
#        dumpInfoLine "... copying .env.example to .env"
#        try
#        (
#            cp -rp "${path}/.env.example" "${path}/.env" || throw 100
#            dumpInfoLine "... ... ${BGre}done${RCol}"
#        )
#        catch || {
#            dumpInfoLine "... ... ${BRed}error${RCol} (unknown)"
#        }
        dumpInfoLine "... ${BRed}error${RCol} (.env does not exist, please copy from .env.example and make settings)"
        dumpInfoLine "... ... ${BRed}can not exexute 'npm run generate' without it${RCol}"
        return
    fi

    # Dump the info line
    dumpInfoLine "... npm run generate"

    # Generate
    #npm run generate >/dev/null 2>&1
    npm run generate

    # Dump the info line
    dumpInfoLine "... ... ${BGre}done${RCol}"
}
