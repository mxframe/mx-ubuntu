# ================================================
# Function to display system information
# ================================================
sysInfo () {
    printf "CPU: "
    cat /proc/cpuinfo | grep "model name" | head -1 | awk '{ for (i = 4; i <= NF; i++) printf "%s ", $i }'
    printf "\n"
    uname -a | awk '{ printf "Kernel: %s " , $3 }'
    uname -m | awk '{ printf "%s" , $1 }'
    printf "\n"
    kded4 --version | grep "KDE Development Platform" | awk '{ printf "KDE: %s", $4 }'
    printf "\n"
    uptime | awk '{ printf "Uptime: %s %s %s", $3, $4, $5 }' | sed 's/,//g'
    printf "\n"
    cputemp | head -1 | awk '{ printf "%s %s %s\n", $1, $2, $3 }'
    cputemp | tail -1 | awk '{ printf "%s %s %s\n", $1, $2, $3 }'
}

# ================================================
# Function to display cpu information
# ================================================
alias cpuInfo='cat /proc/cpuinfo'

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
# Function to display the disk usage
# ================================================
ssd () {
    echo "Device         Total  Used  Free  Pct MntPoint"
    df -h | grep "/dev/sd"
    df -h | grep "/mnt/"
}
