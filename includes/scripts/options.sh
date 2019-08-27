#!/bin/bash

# ================================================
# Options for the shell script
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# ================================================

# Define the options
declare -g -A options
declare -g -A availableOptions

# Define the available options and the help
availableOptions['-h | --help']+="Show the help"
availableOptions['-d | --debug']+="If set, debugging will be enabled"
availableOptions['--sudopw:']+="Option to set the sudo password"

# Read all options
readOptions() {
    # Saner programming env: these switches turn some bugs into errors
    set -o errexit -o pipefail -o noclobber -o nounset

    # Allow a command to fail with !’s side effect on errexit
    # Use return value from ${PIPESTATUS[0]}, because ! hosed $?
    ! getopt --test > /dev/null
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        echo -e "${BRed}Error${RCol}: `getopt --test` failed in this environment."
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
        echo 'List all options with -h or --help'
        exitScript
    fi

    # Read getopt’s output this way to handle the quoting right:
    eval set -- "$PARSED"

    # Parse the options
    while true
    do
        case "$1" in
            ?|-h|--help)
                # Show the help
                for key in "${!availableOptions[@]}"
                do
                ### @todombe add values after :
                    echo -e "[ ${BYel}${key}${RCol} ] ${availableOptions[${key}]}"
                done
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
                    break
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
    if [[ -v options['debug'] ]]
    then
        for x in "${!options[@]}"
        do
            printf "[%s]=%s\n" "$x" "${options[$x]}"
        done
    fi
}

getOption() {
    if [[ -v options[$1] ]]
    then
        return options[$1]
    fi
    return false
}