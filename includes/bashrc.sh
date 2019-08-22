# Define custom prompt
export PS1='\[\033[01;35m\]\u\[\033[00m\] @ \[\033[01;32m\]\h\[\033[00m\] in \[\033[01;34m\]\w\[\033[00m\] '

# Define the gitprompt
# https://github.com/magicmonty/bash-git-prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_START="${PS1}on"
    GIT_PROMPT_END=""
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
