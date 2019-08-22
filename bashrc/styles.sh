#!/bin/bash

# ================================================
# Colorful Manpages
# ================================================
export LESS_TERMCAP_mb=$(printf '\e[01;31m')    # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m')    # enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m')        # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m')        # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m')    # enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m')        # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m')    # enter underline mode – cyan

# ================================================
# Define custom prompt
# ================================================
export PS1='\[\033[01;35m\]\u\[\033[00m\] @ \[\033[01;32m\]\h\[\033[00m\] in \[\033[01;34m\]\w\[\033[00m\]: '

# ================================================
# Define the gitprompt
# https://github.com/magicmonty/bash-git-prompt
# ================================================
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_START="${PS1:0:-2} on"
    GIT_PROMPT_END=": "
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
