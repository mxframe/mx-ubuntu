#!/bin/bash

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
    echo $(getent passwd $1)
}

# ================================================
# Add a new user with a password
#
# @usage
# addUserWithKey "${username}" "${password}"
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithPassword() {
    # Dump the header
    dumpInfoHeader "Adding new user with password"

    # Define the locals
    local username=${1:-'missing'}
    local password=${2:-'missing'}

    # Check the username
    if [[ ${username} = 'missing' ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check the password
    if [[ ${password} = 'missing' ]]
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
        dumpInfoLine "${BGre}Done${RCol}"
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
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error"
            ;;
        esac
        exitScript
    }
}

# ================================================
# Add a new user with a key
#
# @usage
# addUserWithKey "${username}" "${key}"
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithKey() {
    # Dump the header
    dumpInfoHeader "Adding new user with key"

    # Define the locals
    local username=${1:-'missing'}
    local key=${2:-'missing'}

    # Check the username
    if [[ ${username} = 'missing' ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check the key
    if [[ ${key} = 'missing' ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The key is required"
        exitScript
    fi

    # Add the user
    try
    (
        # Add the user
        sudo adduser ${username} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password >/dev/null 2>&1 || throw 100

        # Create the ssh directory
        sudo mkdir /home/${username}/.ssh || throw 101

        # Add the key
        echo "${key}" | sudo tee -a /home/${username}/.ssh/authorized_keys >/dev/null 2>&1 || throw 102

        # Change the permissions and owner
        sudo chmod -R 700 /home/${username}/.ssh
        sudo chown -R ${username}:${username} /home/${username}/.ssh

        # Dump the info
        dumpInfoLine "${BGre}Done${RCol}"
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the user '${username}'"
            ;;

            101)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the ssh directory"
            ;;

            102)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when setting the key"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error"
            ;;
        esac
        exitScript
    }
}

# ================================================
# Add a new user with a password and a key
#
# @usage
# addUserWithPasswordAndKey "${username}" "${password}" "${key}"
#
# https://unix.stackexchange.com/questions/79909/how-to-add-a-unix-linux-user-in-a-bash-script
# ================================================
addUserWithPasswordAndKey() {
    # Dump the header
    dumpInfoHeader "Adding new user with password and key"

    # Define the locals
    local username=${1:-'missing'}
    local password=${2:-'missing'}
    local key=${3:-'missing'}

    # Check the username
    if [[ ${username} = 'missing' ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check the password
    if [[ ${password} = 'missing' ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The password is required"
        exitScript
    fi

    # Check the key
    if [[ ${key} = 'missing' ]]
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
        echo "${key}" | sudo tee -a /home/${username}/.ssh/authorized_keys >/dev/null 2>&1 || throw 103

        # Change the permissions and owner
        sudo chmod -R 700 /home/${username}/.ssh
        sudo chown -R ${username}:${username} /home/${username}/.ssh

        # Dump the info
        dumpInfoLine "${BGre}Done${RCol}"
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
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error"
            ;;
        esac
        exitScript
    }
}
