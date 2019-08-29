#!/bin/bash

# ================================================
# Check if a group exists
#
# @usage
# if [[ $(groupExists GROUPNAME) = true ]]; then ...
# ================================================
groupExists() {
    # Define the locals
    local groupname=${1:-''}

    # Check the groupname
    if stringIsEmptyOrNull ${groupname}
    then
        # Echo false
        echo false
        return
    fi

    # Check the group
    egrep -i "^${groupname}:" /etc/group >/dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
       echo true
    else
       echo false
    fi
}

# ================================================
# Check if a group exists
#
# @usage
# groupAdd GROUPNAME
# ================================================
groupAdd() {
    # Dump the header
    dumpInfoHeader "Adding new group"

    # Define the locals
    local groupname=${1:-''}

    # Check the groupname
    if stringIsEmptyOrNull ${groupname}
    then
        dumpInfoLine "${BRed}Error${RCol}: The groupname is required"
        exitScript
    fi
    dumpInfoLine "Groupname is '${groupname}'"

    # Check if the group already exists
    if [[ $(groupExists "${groupname}") = true ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The group '${groupname}' already exists"
        exitScript
    fi

    # Add the group
    try
    (
        # Add the group
        sudo groupadd ${groupname} >/dev/null 2>&1 || throw 100

        # Dump the info
        dumpInfoLine "${BGre}Done${RCol}"
    )
    catch || {
        case ${exCode} in
            100)
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the group '${groupname}'"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#1]"
            ;;
        esac
        exitScript
    }
}

# ================================================
# Add an user to a group
#
# @usage
# addUserToGroup USERNAME GROUPNAME ${noHeader}
# ================================================
addUserToGroup() {
    # Define the locals
    local username=${1:-''}
    local groupname=${2:-''}
    local noHeader=${3:-false}

    # Dump the header
    if [[ ${noHeader} = true ]]
    then
        dumpInfoLine "Adding user to group"
    else
        dumpInfoHeader "Adding user to group"
    fi

    # Check the username
    if stringIsEmptyOrNull ${username}
    then
        dumpInfoLine "${BRed}Error${RCol}: The username is required"
        exitScript
    fi
    dumpInfoLine "Username is '${username}'"

    # Check if the user exists
    if [[ $(userExists "${username}") = false ]]
    then
        dumpInfoLine "${BRed}Error${RCol}: The user '${username}' does not exist"
        exitScript
    fi

    # Check the groupname
    if stringIsEmptyOrNull ${groupname}
    then
        dumpInfoLine "${BRed}Error${RCol}: The groupname is required"
        exitScript
    fi
    dumpInfoLine "Groupname is '${groupname}'"

    # Check if the group exists
    if [[ $(groupExists "${groupname}") = false ]]
    then
        # Create the group
        dumpInfoLine "${BBlu}Info${RCol}: Creating the group '${groupname}'"
        try
        (
            # Add the group
            sudo groupadd ${groupname} >/dev/null 2>&1 || throw 100

            # Dump the info
            dumpInfoLine "... ${BGre}done${RCol}"
        )
        catch || {
            case ${exCode} in
                100)
                    dumpInfoLine "${BRed}Error${RCol}: There was an error, when creating the group '${groupname}'"
                ;;

                *)
                    dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#1]"
                ;;
            esac
            exitScript
        }
    fi

    # Add user to the group
    try
    (
        # Perform the command
        sudo adduser ${username} ${groupname} >/dev/null 2>&1 || throw 100

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
                dumpInfoLine "${BRed}Error${RCol}: There was an error, when adding user '${username}' to the group '${groupname}'"
            ;;

            *)
                dumpInfoLine "${BRed}Error${RCol}: There was an unknown error [#2]"
            ;;
        esac
        exitScript
    }
}
