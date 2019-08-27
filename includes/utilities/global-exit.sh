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
    kill -s TERM ${processId}
    exit
}
exitScript() {
    exitAll
}
