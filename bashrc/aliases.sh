#!/bin/bash

# ================================================
# Function to display system information
# ================================================
function printSysInfo() {
    printf "CPU: "
    cat /proc/cpuinfo | grep "model name" | head -1 | awk '{ for (i = 4; i <= NF; i++) printf "%s ", $i }'
    printf "\n"
    printf "OS: "
    cat /etc/issue | awk '{ printf "%s %s %s" , $1 , $2 , $3 }'
    printf "\n"
    uname -a | awk '{ printf "Kernel: %s " , $3 }'
    uname -m | awk '{ printf "%s" , $1 }'
    printf "\n"
    kded4 --version | grep "KDE Development Platform" | awk '{ printf "KDE: %s", $4 }'
    printf "\n"
    uptime | awk '{ printf "Uptime: %s %s %s", $3, $4, $5 }' | sed 's/,//g'
}

# ================================================
# Function to display shorter system uptime
# ================================================
function printSysUptime() {
    uptime | awk '{ print "Uptime:", $3, $4, $5 }' | sed 's/,//g'
    return;
}

# ================================================
# Function to display the disk usage
# ================================================
function printDiskUsage() {
    echo "Device         Total  Used  Free  Pct MntPoint"
    df -h | grep "/dev/xvda1"
}

# ================================================
# Function to display/list the installed packages
# ================================================
function printPackagesByName() {
    apt-cache pkgnames | grep -i "$1" | sort
    return;
}

# ================================================
# Function to display cpu information
# ================================================
alias printCpuInfo='cat /proc/cpuinfo'

# ================================================
# Function to make a git pull and source the .bashrc
# ================================================
alias pullAndSource='git pull && source ~/.bashrc'

# ================================================
# Apache aliases
# ================================================
alias a2status='sudo service apache2 status'
alias a2start='sudo service apache2 start'
alias a2reload='sudo service apache2 reload'
alias a2restart='sudo service apache2 restart'
alias a2stop='sudo service apache2 stop'

# ================================================
# mySql aliases
# ================================================
alias msqlStatus='sudo service msqld status'
alias msqlStart='sudo service msqld start'
alias msqlReload='sudo service msqld reload'
alias msqlRestart='sudo service msqld restart'
alias msqlStop='sudo service msqld stop'

# ================================================
# File and folder aliases
# ================================================
# Allow
alias allowR='chmod +r'
alias allowW='chmod +w'
alias allowX='chmod +x'
alias allowRead='allowR'
alias allowWrite='allowW'
alias allowExecute='allowX'
# Disallow
alias disallowR='chmod -r'
alias disallowW='chmod -w'
alias disallowX='chmod -x'
alias disallowRead='disallowR'
alias disallowWrite='disallowW'
alias disallowExecute='disallowX'
# Change directory
alias back='cd "$OLDPWD"'
alias cdBack='back'
# Directory listing alias ll for not existing alias
alias ll='ls -l'
# Long listing, human-readable, sort by extension, do not show group info
alias lll='ls -lhXG'
# Removing Non-Empty Directories, Read-Only Files
alias remove='rm -rf'
# Unpack
alias untarz='tar -xzf'
alias untarj='tar -xjf'

# ================================================
# All directory aliases
# ================================================
declare pathAll="${HOME}/all"
function pathAll() {
    return ${pathAll}
}
function cdAll() {
    cd "${pathAll}"
}