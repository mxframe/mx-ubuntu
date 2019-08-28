#!/bin/bash

# ================================================
# Options for the shell script
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# https://linuxconfig.org/how-to-use-getopts-to-parse-a-script-options
# ================================================

# Define the options
declare -g -A options
declare -g -A availableOptions
declare activeOptionsString

# Define the available options and the help
availableOptions['-h | --help']="Show the help"

# Read all options
readOptions() {
    # Define the active options string
    activeOptionsString=''

    # Saner programming env: these switches turn some bugs into errors
    set -o errexit -o pipefail -o noclobber -o nounset

    # Allow a command to fail with !’s side effect on errexit
    # Use return value from ${PIPESTATUS[0]}, because ! hosed $?
    ! getopt --test > /dev/null
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        dumpError '`getopt --test` failed in this environment'
        exitScript
    fi

    # Define the options check
    local shortOptions=''
    local longOptions=''

    # Looping through keys and values in an associative array
    local key=null
    local -A keys=()
    local subKey=null
    local shortKey=null
    for key in "${!availableOptions[@]}"
    do
        # Trim the key
        trimmed=$(stringRemoveWhitespaces "${key}")

        # Try to split into keys
        local -a tmpKeys=()
        IFS="|" read -a tmpKeys <<<"$trimmed"

        # Loop through the keys
        local shortKeys=''
        for subKey in "${tmpKeys[@]}"
        do
            # Define the options & short keys
            if [[ ${subKey:0:2} = '--' ]]
            then
                # trim the short key and remember, incl. ':'
                shortKey=${subKey:2}
                longOptions+=",${shortKey}"

                # Now trim the '.'
                if [[ ${shortKey:(-1)} = ':' ]]
                then
                    subKey=${subKey:0:(-1)}
                    shortKey=${shortKey:0:(-1)}
                fi
            else
                # trim the short key and remember, incl. ':'
                shortKey=${subKey:1}
                shortOptions+="${shortKey}"

                # Now trim the '.'
                if [[ ${shortKey:(-1)} = ':' ]]
                then
                    subKey=${subKey:0:(-1)}
                    shortKey=${shortKey:0:(-1)}
                fi
            fi
            shortKeys+="|${shortKey}"
        done
        # Remember the short keys & remove the trailing stripe
        if ! stringIsEmptyOrNull "${shortKeys}"
        then
            for subKey in "${tmpKeys[@]}"
            do
                # Check for ':'
                if [[ ${subKey:(-1)} = ':' ]]
                then
                    keys["${subKey:0:(-1)}"]+=${shortKeys:1}
                else
                    keys["${subKey}"]+=${shortKeys:1}
                fi
            done
        fi
    done
    # Remove the trailing comma
    if ! stringIsEmptyOrNull "${longOptions}"
    then
        longOptions=${longOptions:1}
    fi

    # Regarding ! and PIPESTATUS see above
    # temporarily store output to be able to check for errors
    # activate quoting/enhanced mode (e.g. by writing out “--options”)
    # pass arguments only via -- "$@" to separate them correctly
    ! PARSED=$(getopt --options=${shortOptions} --longoptions=${longOptions} --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        # then getopt has complained about wrong arguments to stdout
        dumpError 'Incorrect options were passed'
        echo 'List all options with -h or --help'
        exitScript
    fi

    # Read getopt’s output this way to handle the quoting right:
    eval set -- "$PARSED"

    # Parse the options
    while true
    do
        # Remember the option
        if [[ $1 != '--' && $1 != '--sudopw' ]]
        then
            activeOptionsString+=" $1"
        fi

        # Switch by case
        case $1 in
            -h|--help)
                # Show the help
                echo ''
                dumpInfoHeader 'Usage'
                dumpInfoLine './setup.sh -abc -sudopw VALUE'
                dumpInfoHeader 'Available Options are:'
                for key in "${!availableOptions[@]}"
                do
                    if [[ ${key:(-1)} = ':' ]]
                    then
                        echo -e "[ ${BYel}${key:0:(-1)}${RCol} ${BCya}VALUE${RCol} ] ${availableOptions[${key}]}"
                    else
                        echo -e "[ ${BYel}${key}${RCol} ] ${availableOptions[${key}]}"
                    fi
                done
                echo ''
                exitScript
            ;;

            --)
                # Just skip this option
                shift
                break
            ;;

            *)
                # Check if the key exists
                if [[ ! -v keys[$1] ]]
                then
                    # The key does not exist, so it is a value
                    shift
                    continue
                fi

                # Split the option keys
                local -a tmpKeys=()
                IFS="|" read -a tmpKeys <<<"${keys[$1]}"

                # Loop through the keys
                for subKey in "${tmpKeys[@]}"
                do
                    # Check if there is a value
                    if [[ -z $2 || $2 == "null" || ${2:0:1} = '-' ]]
                    then
                        options["${subKey}"]=true
                    else
                        options["${subKey}"]=$2
                    fi
                done
                shift
            ;;
        esac
    done

    # Print the options, when debug is enabled
    if getOption 'debug'
    then
        # Print the debug message
        clear
        echo -e "${BBlu}Info${RCol}: ${BGre}DEBUG IS ON${RCol}"

        echo ''
        echo -e "${BYel}Options are${RCol}:"
        for x in "${!options[@]}"
        do
            printf " ${BGre}>${RCol} [${BWhi}%s${RCol}]=%s\n" "$x" "${options[$x]}"
        done
    fi
}

# ================================================
# Get an option
#
# @usage
# if getOption 'debug'; then ...
# ================================================
getOption() {
    # Check the option
    if [[ -v options[$1] ]]
    then
        # Return the value
        case ${options[$1]} in
            true|0)
                return 0
            ;;

            false|1)
                return 1
            ;;

            *)
                echo ${options[$1]}
                return
            ;;
        esac
    fi

    # Option not found
    return 1
}

# ================================================
# Echo an option
#
# @usage
# if [[ $(echoOption 'debug') = true ]]; then ...
# ================================================
echoOption() {
    # Check the option
    if [[ -v options[$1] ]]
    then
        # Echo the value
        echo ${options[$1]}
        return
    fi

    # Option not found
    echo false
    return
}

# ================================================
# Get the active options string
#
# @usage
# $(getActiveOptionsString)
# ================================================
getActiveOptionsString() {
    echo ${activeOptionsString}
}
