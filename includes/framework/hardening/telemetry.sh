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
    telFirewall
    telInstallClamAV
    telInstallFail2Ban
    telRemovePackages
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
# Firewall
# Ubuntu firewall, based on IpTables (NetFilter)
#
# @usage
# telFirewall
#
# @info
# Dumps info lines
# ================================================
telFirewall() {
    # Dump the intro line
    dumpInfoLine 'Firewall'

    # Perform the hardening
    sudo apt-get -q -qq install ufw -y 2>/dev/null

    # Perform the hardening
    # uncomment, if you need another ufw config without ipv6
    # ADD ANOTHER RULES MANUALLY FOR YOUR SOFTWARE, IF YOU NEED IT!
    # sudo mv /etc/default/ufw /etc/default/ufw.backup
    # sudo cp -r ufw /etc/default/ufw
    sudo ufw default deny incoming 2>/dev/null # blocks any income traffic
    sudo ufw default deny outgoing 2>/dev/null # blocks any outgoing traffic
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
# Fail2Ban Installation
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
    dumpInfoLine 'Fail2Ban Installation'

    # Perform the hardening
    sudo apt-get -q -qq install fail2ban -y 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Remove packages
#
# @usage
# telRemovePackages
#
# @info
# Dumps info lines
# ================================================
telRemovePackages() {
    # Dump the intro line
    dumpInfoLine 'Remove Packages'

    # Perform the hardening
    # Remove printers
    sudo apt-get -q -qq purge cups cups-server-common -y 2>/dev/null
    # Remove remmina remote connection tool [has libruaries for remote connection, which can be unsecure]
    sudo apt-get -q -qq purge remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc -y 2>/dev/null
    # Just remove it, because of potential telemetry from unity8, which is in beta state and exists only for preview, for now you can use 7 version [potential problem]
    sudo apt-get -q -qq purge unity8* -y 2>/dev/null
    # Desktop server from unity8 [potential problem]
    sudo apt-get -q -qq purge libmirserver41 -y 2>/dev/null
    # Remote tool for gnome debug
    sudo apt-get -q -qq purge gdbserver -y 2>/dev/null
    # Virtual file system [potential problem]
    sudo apt-get -q -qq purge gvfs-fuse -y 2>/dev/null
    # I just don't like "server" word here. Potentional connection possibility? [potential problem]
    sudo apt-get -q -qq purge evolution-data-server -y 2>/dev/null
    sudo apt-get -q -qq purge evolution-data-server-utouch -y 2>/dev/null
    sudo apt-get -q -qq purge evolution-data-server-online-accounts -y 2>/dev/null
    # libfolks is a library that aggregates people from multiple sources (eg, Telepathy connection managers for IM contacts, Evolution Data Server for local contacts, libsocialweb for web service contacts, etc.) to create metacontacts. [potential problem]
    sudo apt-get -q -qq purge libfolks-eds25* -y 2>/dev/null
    # Telemetric package manager from canonical
    sudo apt-get -q -qq purge snapd -y 2>/dev/null
    # Http server for perl
    sudo apt-get -q -qq purge libhttp-daemon-perl -y 2>/dev/null
    # Vnc server (remote desktop share tool)
    sudo apt-get -q -qq purge vino -y 2>/dev/null
    # [potential problem]
    sudo apt-get -q -qq purge unity-scope-video-all -y 2>/dev/null
    sudo apt-get -q -qq purge unity-scope-video-remote -y 2>/dev/null
    # Can be used for virtualization [potential problem]
    sudo apt-get -q -qq purge xserver-xorg-video-vmware -y 2>/dev/null
    # Bad software can use it for proxy servers connections [potential problem]
    sudo apt-get -q -qq purge openvpn -y 2>/dev/null
    # Autoremove all other unused packages after uninstallation
    sudo apt-get -q -qq autoremove -y 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
