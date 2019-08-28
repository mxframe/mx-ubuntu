#!/bin/bash

# ================================================
# Telemetry
#
# This Bash script just removes pre-installed Telemetry and pre-installed software and libs with potentional or high risk.
# Script removes them to make you experience better and more secure.
#
# This script removes several obviously insecure features of Ubuntu.
# Please do not imagine it secures your machine against serious adversaries however.
#
# https://github.com/butteff/Ubuntu-Telemetry-Free-Privacy-Secure
# ================================================
hardeningWithTelemetry() {
    # ================================================
    # Print the info header
    # ================================================
    dumpInfoHeader 'Hardening with telemetry'

    # ================================================
    # Call the necessary functions
    # ================================================
    telRemoveAws
    telRemoveAptUrl
    telInstallDnsEncryption
    telFirewallPart1
    telFirewallPart2
    telInstallClamAV
    telInstallFail2Ban
}

# ================================================
# Amazon & web apps Removing
#
# @usage
# telRemoveAws
#
# @info
# Dumps info lines
# ================================================
telRemoveAws() {
    # Dump the intro line
    dumpInfoLine 'Amazon & web apps Removing'

    # Perform the hardening
    sudo apt-get -q -qq purge unity-lens-shopping -y 2>/dev/null
    sudo apt-get -q -qq purge unity-webapps-common -y 2>/dev/null


    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# AptUrl Removing
#
# @usage
# telRemoveAptUrl
#
# @info
# Dumps info lines
# ================================================
telRemoveAptUrl() {
    # Dump the intro line
    dumpInfoLine 'AptUrl Removing'

    # Perform the hardening
    sudo apt-get -q -qq purge unity-lens-shopping -y 2>/dev/null
    sudo apt-get -q -qq purge unity-webapps-common -y 2>/dev/null


    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# DNS encryption
# ------------------------------------------------
# A tool, which helps to protect dns leak
# Should to be manually configured and added to ufw. Just read all the section "Trouble Shooting" here and google "How To Install DNSCrypt on Ubuntu"].
# ------------------------------------------------
# Trouble Shooting:
# 	if internet will not work, try to restart dnscrypt-proxy:
# 		sudo /etc/init.d/dnscrypt-proxy restart
# 	Also, may be tool will use some another port, detect the port in this output:
# 		sudo ss -ntulp
# 	Then add the port to ufw:
# 		sudo ufw allow out [portnumber]
# 		sudo ufw reload
# ------------------------------------------------
# @usage
# telInstallDnsEncryption
#
# @info
# Dumps info lines
# ================================================
telInstallDnsEncryption() {
    # Dump the intro line
    dumpInfoLine 'DNS encryption'

    # Perform the hardening
    sudo apt-get -q -qq install dnscrypt-proxy -y 2>/dev/null


    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Firewall [Part 1]
# Ubuntu firewall, based on IpTables (NetFilter)
#
# @usage
# telFirewallPart1
#
# @info
# Dumps info lines
# ================================================
telFirewallPart1() {
    # Dump the intro line
    dumpInfoLine 'Firewall [Part 1]'

    # Perform the hardening
    sudo apt-get -q -qq install ufw -y 2>/dev/null


    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Firewall [Part 2]
# uncomment, if you need another ufw config without ipv6
# ADD ANOTHER RULES MANUALLY FOR YOUR SOFTWARE, IF YOU NEED IT!
#
# @usage
# telFirewallPart2
#
# @info
# Dumps info lines
# ================================================
telFirewallPart2() {
    # Dump the intro line
    dumpInfoLine 'Firewall [Part 2]'

    # Perform the hardening
    # sudo mv /etc/default/ufw /etc/default/ufw.backup
    # sudo cp -r ufw /etc/default/ufw
    sudo ufw default deny incoming 2>/dev/null #blocks any income traffic
    sudo ufw default deny outgoing 2>/dev/null #blocks any outgoing traffic
    # Allow web http connections
    sudo ufw allow out 80 2>/dev/null
    # Allow web https connections
    sudo ufw allow out 443 2>/dev/null
    # Enable UFW
    echo 'y' | sudo ufw enable 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# ClamAV Antivirus Installation
#
# @usage
# telInstallClamAV
#
# @info
# Dumps info lines
# ================================================
telInstallClamAV() {
    # Dump the intro line
    dumpInfoLine 'ClamAV Antivirus Installation'

    # Perform the hardening
    sudo apt-get -q -qq install clamav -y 2>/dev/null
    sudo apt-get -q -qq install clamav-daemon -y 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Fail2Ban installation
# (protects from brute force login)
#
# @usage
# telInstallClamAV
#
# @info
# Dumps info lines
# ================================================
telInstallFail2Ban() {
    # Dump the intro line
    dumpInfoLine 'Fail2Ban installation'

    # Perform the hardening
    sudo apt-get -q -qq install fail2ban -y 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
