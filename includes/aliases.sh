# ================================================
# Function to get system information
# ================================================
sysinfo () {
  printf "CPU: "
  cat /proc/cpuinfo | grep "model name" | head -1 | awk '{ for (i = 4; i <= NF; i++) printf "%s ", $i }'
  printf "\n"

  cat /etc/issue | awk '{ printf "OS: %s %s %s %s | " , $1 , $2 , $3 , $4 }'
  uname -a | awk '{ printf "Kernel: %s " , $3 }'
  uname -m | awk '{ printf "%s | " , $1 }'
  kded4 --version | grep "KDE Development Platform" | awk '{ printf "KDE: %s", $4 }'
  printf "\n"
  uptime | awk '{ printf "Uptime: %s %s %s", $3, $4, $5 }' | sed 's/,//g'
  printf "\n"
  cputemp | head -1 | awk '{ printf "%s %s %s\n", $1, $2, $3 }'
  cputemp | tail -1 | awk '{ printf "%s %s %s\n", $1, $2, $3 }'
  #cputemp | awk '{ printf "%s %s", $1 $2 }'
}

# ================================================
# Apache aliases
# ================================================
alias a2start='sudo service apache2 start'
alias a2reload='sudo service apache2 reload'
alias a2restart='sudo service apache2 restart'
alias a2stop='sudo service apache2 stop'

# ================================================
# mySql aliases
# ================================================
alias msqlStart='sudo service msqld start'
alias msqlReload='sudo service msqld reload'
alias msqlRestart='sudo service msqld restart'
alias msqlStop='sudo service msqld stop'
