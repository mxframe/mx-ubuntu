#!/bin/bash

# ================================================
# Debug functions
# ================================================

# ================================================
# Dump a value (if debug is on)
#
# @usage
# dd ${variable} ${title} ${titleColor}
#
# @info
# ${title} is optional
# ${titleColor} is optional
# ================================================
dd() {
    # Check for title
    local title=${2:-'Debug-Dump'}

    # Check for title color
    local titleColor=${3:-${BGre}}

    # Check if debug is enabled
    if getOption 'debug'
    then
        # Dump the value
        echo '' >&2
        echo -e "${titleColor}${title}${RCol}" >&2
        echo -e " ${BGre}>${RCol} $1" >&2
    fi
}

# ================================================
# Dump a value
#
# @usage
# dump ${variable} ${title} ${titleColor}
#
# @info
# ${title} is optional
# ${titleColor} is optional
# ================================================
dump() {
    # Check for title
    local title=${2:-'Debug-Dump'}

    # Check for title color
    local titleColor=${3:-${BGre}}

    # Dump the value
    echo '' >&2
    echo -e "${titleColor}${title}${RCol}" >&2
    echo -e " ${BGre}>${RCol} $1" >&2
}

# ================================================
# Dump an error message
#
# @usage
# dumpError ${message}
# ================================================
dumpError() {
    # Dump the value
    echo '' >&2
    echo -e "${BRed}Error${RCol}" >&2
    echo -e " ${BRed}>${RCol} $1" >&2
}

# ================================================
# Dump an info header
#
# @usage
# dumpInfoHeader ${text}
# ================================================
dumpInfoHeader() {
    echo '' >&2
    echo -e "${BBlu}$1${RCol}" >&2
}

# ================================================
# Dump an info line
#
# @usage
# dumpInfoLine ${text}
# ================================================
dumpInfoLine() {
    echo -e " ${BBlu}>${RCol} $1" >&2
}

# ================================================
# Dump an error line
#
# @usage
# dumpErrorLine ${text}
# ================================================
dumpErrorLine() {
    echo -e " ${BRed}> Error:${RCol} $1" >&2
}
