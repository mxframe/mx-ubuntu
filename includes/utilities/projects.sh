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
    # Search for the git projects
    local gitProjects=( $(findGitProjects ${pathProjects}) )

    # Iterate through the git projects
    for project in "${gitProjects[@]}"
    do
        # Increase the counter
        (( $projectsCount++ ))

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
}

# ================================================
# Update the projects
# ================================================
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

    # Iterate through the projects to update
    for project in "${!updateProjectsTotal[@]}"
    do
        # Dump the info line
        dumpInfoHeader "Updating ${project}"

        # Check the backend [needs to be first]
        if [[ -v updateProjectsBackend[${project}] ]]
        then
            updateBackendProject "${project}"
        fi

        # Check the undefined [needs to be second]
        if [[ -v updateProjectsUndefined[${project}] ]]
        then
            updateUndefinedProject "${project}"
        fi

        # Check the backend [needs to be third]
        if [[ -v updateProjectsFrontend[${project}] ]]
        then
            updateFrontendProject "${project}"
        fi
    done
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

    # Perform the git pull
    projectGitPull "${projectsFrontend[${projectName}]}"

    # Make the composer update
    projectComposerUpdate "${projectsFrontend[${projectName}]}"

    # Make the npm update
    projectNpmInstallAndGenerate "${projectsFrontend[${projectName}]}"
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
    #git reset --hard >/dev/null 2>&1
    git reset --hard

    # Make a git pull
    #git pull >/dev/null 2>&1
    git pull

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
    if [[ -f "${path}/composer.lock" ]] && [[ ${composerLockFileTime} = $(stat -c '%Y' "${path}/composer.lock") ]]
    then
        dumpInfoLine "... composer install"
        dumpInfoLine "... ... ${BYel}not needed${RCol}"
        return
    fi

    # Check for composer.lock
#    if [[ -f "${path}/composer.lock" ]]
#    then
        # Dump the info line
        dumpInfoLine "... composer install"

        # Install
        #composer install >/dev/null 2>&1
        composer install
#    else
#        # Dump the info line
#        dumpInfoLine "... composer update"
#
#        # Update
#        #composer update >/dev/null 2>&1
#        composer update
#    fi

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
        #npm install >/dev/null 2>&1
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