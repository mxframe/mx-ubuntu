#!/bin/bash

# ================================================
# Define the global exit term
# ================================================
trap "exit 1" TERM
export processId=$$

# ================================================
# The global exit function
# ================================================
exitAll() {
    echo ''
    kill -s TERM ${processId}
    exit
}
exitScript() {
    exitAll
}
