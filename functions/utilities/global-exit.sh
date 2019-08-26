#!/bin/bash

# ================================================
# Define the global exit term
# ================================================
trap "exit 1" TERM
export processId=$$

# ================================================
# the global exit function
# ================================================
function exitScript() {
    kill -s TERM ${processId}
}
