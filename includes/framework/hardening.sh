#!/bin/bash

# ================================================
# A security/hardening script
# ================================================

# ================================================
# Set variables of script
# ================================================
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/local/bin:/opt/local/sbin"
PASS_EXP="60" #used to set password expire in days
PASS_WARN="14" #used to set password warning in days
PASS_CHANG="1" #used to set how often you can change password in days
SELINUX=`grep ^SELINUX= /etc/selinux/config 2>/dev/null | awk -F'=' '{ print $2 }'`

# ================================================
# Quick secure
#
# Inspired by
# @link https://github.com/marshyski/quick-secure/
# @link https://github.com/marshyski/quick-secure/blob/master/quick-secure
# ================================================
quickSecure() {
#    # Verify the user wants to harden system
#    if ! getOption 'force'
#    then
#        echo -n "Are you sure you want to quick secure `hostname` (y/N)? "
#        read ANSWER
#        if [[ $ANSWER != "y" ]]
#        then
#            exitScript
#        fi
#
#        echo ''
#    fi

    # ================================================
    # Print the info header
    # ================================================
    dumpInfoHeader 'Using quick secure'

    # ================================================
    # Call the necessary functions
    # ================================================
    turnOffEnforcing
    turnOffSelinux
    hardeningCron
    hardeningOwnerships

    echo 'hier'
    exitScript
}

# ================================================
# Turn off selinux before setting configurations
#
# @usage
# turnOffEnforcing
#
# @info
# Dumps info lines
# ================================================
turnOffEnforcing() {
    if [[ `getenforce 2>/dev/null` = 'Enforcing' ]]
    then
        setenforce 0
        dumpInfoLine 'Turned of enforcing'
    fi
}

# ================================================
# Turn off selinux before setting configurations
#
# @usage
# turnOffSelinux
#
# @info
# Dumps info lines
# ================================================
turnOffSelinux() {
    if [[ -f /etc/sysconfig/selinux ]]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        echo 'SELINUX=disabled' > /etc/sysconfig/selinux
        echo 'SELINUXTYPE=targeted' >> /etc/sysconfig/selinux
        chmod -f 0640 /etc/sysconfig/selinux
        dumpInfoLine 'Turned of Selinux'
    fi
}

# ================================================
# Cron setup/hardening
#
# @usage
# hardeningCron
#
# @info
# Dumps info lines
# ================================================
hardeningCron() {
    # Modify the cron
    if [[ -f /etc/cron.allow ]]
    then
        # Add root to /etc/cron.allow
        if [[ `grep root /etc/cron.allow 2>/dev/null` != 'root' ]]
        then
            echo 'root' > /etc/cron.allow
            rm -f /etc/at.deny
            dumpInfoLine 'Added root to /etc/cron.allow'
        else
            dumpInfoLine 'Root is already in /etc/cron.allow'
        fi

        # Check if at.allow is needed
        if [[ ! -f /etc/at.allow ]]
        then
            touch /etc/at.allow
            dumpInfoLine 'Created /etc/at.allow'
        fi

        # Add root to /etc/at.allow
        if [[ `grep root /etc/at.allow 2>/dev/null` != 'root' ]]
        then
            echo 'root' > /etc/at.allow
            rm -f /etc/at.deny
            dumpInfoLine 'Added root to /etc/at.allow'
        else
            dumpInfoLine 'Root is already in /etc/at.allow'
        fi

        # Check /etc/at.deny
        if [[ `cat /etc/at.deny 2>/dev/null` = '' ]]; then
            rm -f /etc/at.deny
            dumpInfoLine 'Removed /etc/at.deny'
        fi

        # Check /etc/cron.deny
        if [[ `cat /etc/cron.deny 2>/dev/null` = '' ]]; then
            rm -f /etc/cron.deny
            dumpInfoLine 'Removed /etc/cron.deny'
        fi
    fi

    # Changemod for the cron directories
    dumpInfoLine 'Changing permissions of the cron directories'
    [[ -d /etc/cron.monthly ]] && sudo chmod -f 0700 /etc/cron.monthly >/dev/null 2>&1
    [[ -d /etc/cron.weekly ]] && sudo chmod -f 0700 /etc/cron.weekly >/dev/null 2>&1
    [[ -d /etc/cron.daily ]] && sudo chmod -f 0700 /etc/cron.daily >/dev/null 2>&1
    [[ -d /etc/cron.hourly ]] && sudo chmod -f 0700 /etc/cron.hourly >/dev/null 2>&1
    [[ -d /var/spool/cron ]] && sudo chmod -f 0700 /var/spool/cron >/dev/null 2>&1
    [[ -d /var/spool/at ]] && sudo chmod -f 0700 /var/spool/at >/dev/null 2>&1
    dumpInfoLine "... ${BGre}done${RCol}"

    # Changemod for the cron files
    dumpInfoLine 'Changing permissions of the cron files'
    # Files i a directory
    [[ -d /etc/cron.monthly ]] && [[ "$(sudo ls -A /etc/cron.monthly)" ]] && sudo chmod -f 0700 /etc/cron.monthly/* >/dev/null 2>&1
    [[ -d /etc/cron.weekly ]] && [[ "$(sudo ls -A /etc/cron.weekly)" ]] && sudo chmod -f 0700 /etc/cron.weekly/* >/dev/null 2>&1
    [[ -d /etc/cron.daily ]] && [[ "$(sudo ls -A /etc/cron.daily)" ]] && sudo chmod -f 0700 /etc/cron.daily/* >/dev/null 2>&1
    [[ -d /etc/cron.hourly ]] && [[ "$(sudo ls -A /etc/cron.hourly)" ]] && sudo chmod -f 0700 /etc/cron.hourly/* >/dev/null 2>&1
    [[ -d /var/spool/cron ]] && [[ "$(sudo ls -A /var/spool/cron/)" ]] && sudo chmod -f 0600 /var/spool/cron/* >/dev/null 2>&1
    [[ -d /var/spool/at ]] && [[ "$(sudo ls -A /var/spool/at/)" ]] && sudo chmod -f 0600 /var/spool/at/* >/dev/null 2>&1
    [[ -d /etc/cron.d ]] && [[ "$(sudo ls -A /etc/cron.d)" ]] && sudo chmod -f 0700 /etc/cron.d/* >/dev/null 2>&1
    # Specific files
    [[ -f /etc/cron.allow ]] && sudo chmod -f 0400 /etc/cron.allow >/dev/null 2>&1
    [[ -f /etc/cron.deny ]] && sudo chmod -f 0400 /etc/cron.deny >/dev/null 2>&1
    [[ -f /etc/crontab ]] && sudo chmod -f 0400 /etc/crontab >/dev/null 2>&1
    [[ -f /etc/cron.allow ]] && sudo chmod -f 0400 /etc/at.allow >/dev/null 2>&1
    [[ -f /etc/cron.deny ]] && sudo chmod -f 0400 /etc/at.deny >/dev/null 2>&1
    [[ -f /etc/anacrontab ]] && sudo chmod -f 0400 /etc/anacrontab >/dev/null 2>&1
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening the main ownerships
#
# @usage
# hardeningOwnerships
#
# @info
# Dumps info lines
# ================================================
hardeningOwnerships() {
    # Dump the intro line
    dumpInfoLine 'Hardening the ownerships'

    # Hardening the ownerships
    [[ $(fileOrDirectoryExists /tmp) ]] && sudo chmod -f 1777 /tmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/crash) ]] && sudo chown -f root:root /var/crash >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/cache/mod_proxy) ]] && sudo chown -f root:root /var/cache/mod_proxy >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/lib/dav) ]] && sudo chown -f root:root /var/lib/dav >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/lockfile) ]] && sudo chown -f root:root /usr/bin/lockfile >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/lib/nfs/statd) ]] && sudo chown -f rpcuser:rpcuser /var/lib/nfs/statd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/adm) ]] && sudo chown -f adm:adm /var/adm >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/crash) ]] && sudo chmod -f 0600 /var/crash >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/mail) ]] && sudo chown -f root:root /bin/mail >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/reboot) ]] && sudo chmod -f 0700 /sbin/reboot >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/shutdown) ]] && sudo chmod -f 0700 /sbin/shutdown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ssh/ssh*config) ]] && sudo chmod -f 0600 /etc/ssh/ssh*config >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /root) ]] && sudo chown -f root:root /root >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /root) ]] && sudo chmod -f 0700 /root >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ypcat) ]] && sudo chmod -f 0500 /usr/bin/ypcat >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/sbin/usernetctl) ]] && sudo chmod -f 0700 /usr/sbin/usernetctl >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rlogin) ]] && sudo chmod -f 0700 /usr/bin/rlogin >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rcp) ]] && sudo chmod -f 0700 /usr/bin/rcp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/pam.d) ]] && sudo chmod -f 0640 /etc/pam.d/system-auth* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/login.defs) ]] && sudo chmod -f 0640 /etc/login.defs >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security) ]] && sudo chmod -f 0750 /etc/security >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ausearch) ]] && sudo chmod -f 0750 /sbin/ausearch >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ausearch) ]] && sudo chown -f root /sbin/ausearch >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/aureport) ]] && sudo chown -f root /sbin/aureport >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/aureport) ]] && sudo chmod -f 0750 /sbin/aureport >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/autrace) ]] && sudo chown -f root /sbin/autrace >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/autrace) ]] && sudo chmod -f 0750 /sbin/autrace >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/audispd) ]] && sudo chown -f root /sbin/audispd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/audispd) ]] && sudo chmod -f 0750 /sbin/audispd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/bashrc) ]] && sudo chmod -f 0444 /etc/bashrc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh.cshrc) ]] && sudo chmod -f 0444 /etc/csh.cshrc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh.login) ]] && sudo chmod -f 0444 /etc/csh.login >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/client.conf) ]] && sudo chmod -f 0600 /etc/cups/client.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/cupsd.conf) ]] && sudo chmod -f 0600 /etc/cups/cupsd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/client.conf) ]] && sudo chown -f root:sys /etc/cups/client.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/cupsd.conf) ]] && sudo chown -f root:sys /etc/cups/cupsd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/grub.conf) ]] && sudo chmod -f 0600 /etc/grub.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/grub.conf) ]] && sudo chown -f root:root /etc/grub.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub2/grub.cfg) ]] && sudo chmod -f 0600 /boot/grub2/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub2/grub.cfg) ]] && sudo chown -f root:root /boot/grub2/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub/grub.cfg) ]] && sudo chmod -f 0600 /boot/grub/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub/grub.cfg) ]] && sudo chown -f root:root /boot/grub/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/hosts) ]] && sudo chmod -f 0444 /etc/hosts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/hosts) ]] && sudo chown -f root:root /etc/hosts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inittab) ]] && sudo chmod -f 0600 /etc/inittab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inittab) ]] && sudo chown -f root:root /etc/inittab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/sendmail.cf) ]] && sudo chmod -f 0444 /etc/mail/sendmail.cf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/sendmail.cf) ]] && sudo chown -f root:bin /etc/mail/sendmail.cf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ntp.conf) ]] && sudo chmod -f 0600 /etc/ntp.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/access.conf) ]] && sudo chmod -f 0640 /etc/security/access.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/console.perms) ]] && sudo chmod -f 0600 /etc/security/console.perms >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/console.perms.d/50-default.perms) ]] && sudo chmod -f 0600 /etc/security/console.perms.d/50-default.perms >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/limits) ]] && sudo chmod -f 0600 /etc/security/limits >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/services) ]] && sudo chmod -f 0444 /etc/services >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shells) ]] && sudo chmod -f 0444 /etc/shells >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/skel) ]] && sudo chmod -f 0644 /etc/skel/.* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/skel/.bashrc) ]] && sudo chmod -f 0600 /etc/skel/.bashrc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/skel/.bash_profile) ]] && sudo chmod -f 0600 /etc/skel/.bash_profile >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/skel/.bash_logout) ]] && sudo chmod -f 0600 /etc/skel/.bash_logout >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sudoers) ]] && sudo chmod -f 0440 /etc/sudoers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sudoers) ]] && sudo chown -f root:root /etc/sudoers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.conf) ]] && sudo chmod -f 0600 /etc/sysctl.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.conf) ]] && sudo chown -f root:root /etc/sysctl.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) ]] && sudo chown -f root:root /etc/sysctl.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) ]] && sudo chmod -f 0700 /etc/sysctl.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) ]] && sudo chmod -f 0600 /etc/sysctl.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/syslog.conf) ]] && sudo chmod -f 0600 /etc/syslog.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/yp/binding) ]] && sudo chmod -f 0600 /var/yp/binding >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) ]] && sudo chmod -Rf 0640 /var/log/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) ]] && sudo chmod -f 0755 /var/log >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/syslog) ]] && sudo chmod -f 0750 /var/log/syslog >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) ]] && sudo chmod -f 0600 /var/log/lastlog* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) ]] && sudo chmod -f 0600 /var/log/cron* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/btmp) ]] && sudo chmod -f 0600 /var/log/btmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/wtmp) ]] && sudo chmod -f 0660 /var/log/wtmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/profile) ]] && sudo chmod -f 0444 /etc/profile >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rc.d/rc.local) ]] && sudo chmod -f 0700 /etc/rc.d/rc.local >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/securetty) ]] && sudo chmod -f 0400 /etc/securetty >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rc.local) ]] && sudo chmod -f 0700 /etc/rc.local >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/wall) ]] && sudo chmod -f 0750 /usr/bin/wall >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/wall) ]] && sudo chown -f root:tty /usr/bin/wall >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /mnt) ]] && sudo chown -f root:users /mnt >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /media) ]] && sudo chown -f root:users /media >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/.login) ]] && sudo chmod -f 0644 /etc/.login >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/profile.d) ]] && sudo chmod -f 0644 /etc/profile.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/environ) ]] && sudo chown -f root /etc/security/environ >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) ]] && sudo chown -f root /etc/xinetd.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) ]] && sudo chown -f root /etc/xinetd.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) ]] && sudo chmod -f 0750 /etc/xinetd.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) ]] && sudo chmod -f 0640 /etc/xinetd.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/selinux/config) ]] && sudo chmod -f 0640 /etc/selinux/config >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/chfn) ]] && sudo chmod -f 0750 /usr/bin/chfn >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/chsh) ]] && sudo chmod -f 0750 /usr/bin/chsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/write) ]] && sudo chmod -f 0750 /usr/bin/write >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/mount.nfs) ]] && sudo chmod -f 0750 /sbin/mount.nfs >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/mount.nfs4) ]] && sudo chmod -f 0750 /sbin/mount.nfs4 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ldd) ]] && sudo chmod -f 0700 /usr/bin/ldd >/dev/null 2>&1 # 0400 for some systems
    [[ $(fileOrDirectoryExists /bin/traceroute) ]] && sudo chmod -f 0700 /bin/traceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/traceroute) ]] && sudo chown -f root:root /bin/traceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/) ]] && sudo chmod -f 0700 /usr/bin/traceroute6* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/traceroute6) ]] && sudo chown -f root:root /usr/bin/traceroute6 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/tcptraceroute) ]] && sudo chmod -f 0700 /bin/tcptraceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/iptunnel) ]] && sudo chmod -f 0700 /sbin/iptunnel >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/) ]] && sudo chmod -f 0700 /usr/bin/tracpath* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/audio) ]] && sudo chmod -f 0644 /dev/audio >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/audio) ]] && sudo chown -f root:root /dev/audio >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/environment) ]] && sudo chmod -f 0644 /etc/environment >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/environment) ]] && sudo chown -f root:root /etc/environment >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.conf) ]] && sudo chmod -f 0600 /etc/modprobe.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.conf) ]] && sudo chown -f root:root /etc/modprobe.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) ]] && sudo chown -f root:root /etc/modprobe.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) ]] && sudo chown -f root:root /etc/modprobe.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) ]] && sudo chmod -f 0700 /etc/modprobe.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) ]] && sudo chmod -f 0600 /etc/modprobe.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /selinux) ]] && sudo chmod -f o-w /selinux/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc) ]] && sudo chmod -f 0755 /etc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man1) ]] && sudo chmod -f 0644 /usr/share/man/man1/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man5) ]] && sudo chmod -Rf 0644 /usr/share/man/man5 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man1) ]] && sudo chmod -Rf 0644 /usr/share/man/man1 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/yum.repos.d) ]] && sudo chmod -f 0600 /etc/yum.repos.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/fstab) ]] && sudo chmod -f 0640 /etc/fstab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/cache/man) ]] && sudo chmod -f 0755 /var/cache/man >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/init.d/atd) ]] && sudo chmod -f 0755 /etc/init.d/atd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ppp/peers) ]] && sudo chmod -f 0750 /etc/ppp/peers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/ntfs-3g) ]] && sudo chmod -f 0755 /bin/ntfs-3g >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/sbin/pppd) ]] && sudo chmod -f 0750 /usr/sbin/pppd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/chatscripts) ]] && sudo chmod -f 0750 /etc/chatscripts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/local/share/ca-certificates) ]] && sudo chmod -f 0750 /usr/local/share/ca-certificates >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
