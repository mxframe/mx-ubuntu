#!/bin/bash

# ================================================
# Functions for the user management
# ================================================

# Define the default users
declare -g -A defaultUsers
declare -g -A defaultUsersAndGroups

# ================================================
# Ensure that the default users exist and are added to their groups
#
# @usage
# ensureDefaultUsers
# ================================================
ensureDefaultUsers() {
    # Check if debug is enabled
    if getOption 'debug'
    then
        dd 'Next Step, ensure that the users are existinig'
        pressKeyToContinue
    fi

    # Dump the header
    dumpInfoHeader 'Ensure that the default users are existing'

    # Loop through the users
    for username in "${!defaultUsers[@]}"
    do
        # Check if the user exists
        if [[ $(userExists "${username}") = false ]]
        then
            dumpInfoLine "Creating user '${username}'"
            addUserWithKey "${username}" "${defaultUsers[${username}]}" true
        fi

        # Check if the user exists now
        if [[ $(userExists "${username}") = true ]]
        then
            # Add the user to the group
            addUserToGroup "${username}" "${username}" true

            if [[ -v defaultUsersAndGroups[${username}] ]]
            then
                # Trim the groups
                trimmed=$(stringRemoveWhitespaces "${defaultUsersAndGroups[${username}]}")

                # Try to split into groups
                local -a tmpGroups=()
                IFS=',' read -a tmpGroups <<<"$trimmed"

                # Loop through the groups
                for tmpGroup in "${tmpGroups[@]}"
                do
                    addUserToGroup "${username}" "${tmpGroup}" true
                done
            fi
        fi
    done
}

# ================================================
# Check if a user exists
#
# @usage
# if [[ $(userExists USERNAME) = true ]]; then ...
# ================================================
userExists() {
    # Define the locals
    local username=${1:-''}

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        # Echo false
        echo false
        return
    fi

    # Check the group
    egrep -i "^${username}:" /etc/passwd >/dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
       echo true
    else
       echo false
    fi
}

# ================================================
# Get all users and their home directories
#
# @usage
# declare -A myArray
# getUsersWithHome myArray
#
# https://unix.stackexchange.com/questions/462068/bash-return-an-associative-array-from-a-function-and-then-pass-that-associative
# https://www.linuxjournal.com/content/return-values-bash-functions
# https://unix.stackexchange.com/questions/199220/how-to-loop-over-users
# ================================================
getUsersWithHome() {
    # Define the users
    local -n __users="$1"

    # Use awk to do the heavy lifting.
    # For lines with UID>=1000 (field 3) grab the home directory (field 6)
    local usrInfo=$(awk -F: '{if ($3 >= 1000) print $6}' < /etc/passwd)

    # Use newline as delimiter for for-loop
    IFS=$'\n'
    local userHome
    for userHome in ${usrInfo}
    do
        __users["${userHome##*/}"]="${userHome}"
    done
}

# ================================================
# Get user information
#
# @usage
# getUserInformation USER
# ================================================
getUserInformation() {
    # Define the locals
    local username=${1:-''}

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        # Echo empty string
        echo ''
    fi

    # Echo the user information
    echo $(getent passwd ${username})
}

# ================================================
# Add a new user with a password
#
# @usage
# addUserWithKey "${username}" "${password}" ${noHeader}
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithPassword() {
    # Define the locals
    local username=${1:-''}
    local password=${2:-''}
    local dumpInfoHeader=${3:-false}

    # Dump the header
    if [[ ${noHeader} = true ]]
    then
        dumpInfoLine "Adding new user with password"
    else
        dumpInfoHeader "Adding new user with password"
    fi

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check if the user already exists
    if [[ $(userExists "${username}") = true ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The user '${username}' already exists"
        exitScript
    fi

    # Check the password
    if stringIsEmptyOrNull ${password}
    then
        dumpInfoLine "${BRed}Error${RCol}: The password is required"
        exitScript
    fi

    # Add the user
    try
    (
        # Add the user
        sudo adduser ${username} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password >/dev/null 2>&1 || throw 100

        # Set the password
        echo "${username}:${password}" | sudo chpasswd || throw 101

        # Dump the info
        if [[ ${noHeader} = true ]]
        then
            dumpInfoLine "... ${BGre}done${RCol}"
        else
            dumpInfoLine "${BGre}Done${RCol}"
        fi
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the user '${username}'"
            ;;

            101)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the password"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#1]"
            ;;
        esac
        exitScript
    }
}

# ================================================
# Add a new user with a key and a default password
#
# @usage
# addUserWithKey "${username}" "${key}" ${noHeader}
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithKey() {
    # Define the locals
    local username=${1:-''}
    local key=${2:-''}
    local noHeader=${3:-false}

    # Dump the header
    if [[ ${noHeader} = true ]]
    then
        dumpInfoLine "Adding new user with key"
    else
        dumpInfoHeader "Adding new user with key"
    fi

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check if the user already exists
    if [[ $(userExists "${username}") = true ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The user '${username}' already exists"
        exitScript
    fi

    # Check the key
    if stringIsEmptyOrNull ${key}
    then
        dumpInfoLine "${BRed}Error${RCol}: The key is required"
        exitScript
    fi

    # Add the user
    try
    (
        # Add the user
        sudo adduser ${username} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password >/dev/null 2>&1 || throw 100

        # Set the password
        echo "${username}:${defaultUserPassword}" | sudo chpasswd || throw 101

        # Create the ssh directory
        sudo mkdir /home/${username}/.ssh || throw 102

        # Add the key
        echo "${key} ${username}" | sudo tee -a /home/${username}/.ssh/authorized_keys >/dev/null 2>&1 || throw 103
        # @todombe remove later
        if [[ ${username} != 'ubuntu' ]]
        then
            echo "${key} ${username}" | sudo tee -a /home/ubuntu/.ssh/authorized_keys >/dev/null 2>&1 || throw 103
        fi

        # Change the permissions and owner
        sudo chmod -R 700 /home/${username}/.ssh
        sudo chown -R ${username}:${username} /home/${username}/.ssh

        # Dump the info
        if [[ ${noHeader} = true ]]
        then
            dumpInfoLine "... ${BGre}done${RCol}"
        else
            dumpInfoLine "${BGre}Done${RCol}"
        fi
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the user '${username}'"
            ;;

            101)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the password"
            ;;

            102)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the ssh directory"
            ;;

            103)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the key"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#1]"
            ;;
        esac
        exitScript
    }
}

# ================================================
# Add a new user with a password and a key
#
# @usage
# addUserWithPasswordAndKey "${username}" "${password}" "${key}" ${noHeader}
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithPasswordAndKey() {
    # Define the locals
    local username=${1:-''}
    local password=${2:-''}
    local key=${3:-''}
    local noHeader=${4:-false}

    # Dump the header
    if [[ ${noHeader} = true ]]
    then
        dumpInfoLine "Adding new user with password and key"
    else
        dumpInfoHeader "Adding new user with password and key"
    fi

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check if the user already exists
    if [[ $(userExists "${username}") = true ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The user '${username}' already exists"
        exitScript
    fi

    # Check the password
    if stringIsEmptyOrNull ${password}
    then
        dumpInfoLine "${BRed}Error${RCol}: The password is required"
        exitScript
    fi

    # Check the key
    if stringIsEmptyOrNull ${key}
    then
        dumpInfoLine "${BRed}Error${RCol}: The key is required"
        exitScript
    fi

    # Add the user
    try
    (
        # Add the user
        sudo adduser ${username} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password >/dev/null 2>&1 || throw 100

        # Set the password
        echo "${username}:${password}" | sudo chpasswd || throw 101

        # Create the ssh directory
        sudo mkdir /home/${username}/.ssh || throw 102

        # Add the key
        echo "${key} ${username}" | sudo tee -a /home/${username}/.ssh/authorized_keys >/dev/null 2>&1 || throw 103
        # @todombe remove later
        if [[ ${username} != 'ubuntu' ]]
        then
            echo "${key} ${username}" | sudo tee -a /home/ubuntu/.ssh/authorized_keys >/dev/null 2>&1 || throw 103
        fi

        # Change the permissions and owner
        sudo chmod -R 700 /home/${username}/.ssh
        sudo chown -R ${username}:${username} /home/${username}/.ssh

        # Dump the info
        if [[ ${noHeader} = true ]]
        then
            dumpInfoLine "... ${BGre}done${RCol}"
        else
            dumpInfoLine "${BGre}Done${RCol}"
        fi
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the user '${username}'"
            ;;

            101)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the password"
            ;;

            102)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the ssh directory"
            ;;

            103)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the key"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#1]"
            ;;
        esac
        exitScript
    }
}
