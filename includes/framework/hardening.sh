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
    dumpInfoHeader 'Hardening with quick secure'

    # ================================================
    # Turn of enforcing & selinux (needed)
    # ================================================
    turnOffEnforcing
    turnOffSelinux

    # ================================================
    # Call the necessary functions
    # ================================================
    qsHardeningCron
    qsHardeningOwnerships
    qsHardeningClamAV
    qsHardeningDisaStigOwnerships
    qsHardeningSsh

    echo 'hier'
    exitScript
}


# ================================================
# Cron setup/hardening
#
# @usage
# qsHardeningCron
#
# @info
# Dumps info lines
# ================================================
qsHardeningCron() {
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
# qsHardeningOwnerships
#
# @info
# Dumps info lines
# ================================================
qsHardeningOwnerships() {
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

# ================================================
# Hardening ClamAV
#
# @usage
# qsHardeningClamAV
#
# @info
# Dumps info lines
# ================================================
qsHardeningClamAV() {
    # Dump the intro line
    dumpInfoLine 'Checking for ClamAv'

    # Check if the folders exist
    if [[ -d /usr/local/share/clamav ]] || [[ -d /var/clamav ]]
    then
        # Dump the intro line
        dumpInfoLine '... hardening ClamAv'

        # Hardening ClamAV permissions and ownership
        # for /usr/local/share/clamav
        if [[ -d /usr/local/share/clamav ]]
        then
          passwd -l clamav 2>/dev/null
          usermod -s /sbin/nologin clamav 2>/dev/null
          sudo chmod -f 0755 /usr/local/share/clamav >/dev/null 2>&1
          sudo chown -f root:clamav /usr/local/share/clamav >/dev/null 2>&1
          sudo chown -f root:clamav /usr/local/share/clamav/*.cvd >/dev/null 2>&1
          sudo chmod -f 0664 /usr/local/share/clamav/*.cvd >/dev/null 2>&1
          sudo mkdir -p /var/log/clamav >/dev/null 2>&1
          sudo chown -f root:root /var/log/clamav >/dev/null 2>&1
          sudo chmod -f 0640 /var/log/clamav >/dev/null 2>&1
        fi

        # Hardening ClamAV permissions and ownership
        # for /var/clamav
        if [[ -d /var/clamav ]]
        then
          passwd -l clamav 2>/dev/null
          usermod -s /sbin/nologin clamav 2>/dev/null
          sudo chmod -f 0755 /var/clamav >/dev/null 2>&1
          sudo chown -f root:clamav /var/clamav >/dev/null 2>&1
          sudo chown -f root:clamav /var/clamav/*.cvd >/dev/null 2>&1
          sudo chmod -f 0664 /var/clamav/*.cvd >/dev/null 2>&1
          sudo mkdir -p /var/log/clamav >/dev/null 2>&1
          sudo chown -f root:root /var/log/clamav >/dev/null 2>&1
          sudo chmod -f 0640 /var/log/clamav >/dev/null 2>&1
        fi

        # Dump the done line
        dumpInfoLine "... ${BGre}done${RCol}"
    else
        # Dump the not found line
        dumpInfoLine "... ${BRed}not found${RCol}"
    fi
}

# ================================================
# Hardening DISA STIG file ownerships
#
# @usage
# qsHardeningDisaStigOwnerships
#
# @info
# Dumps info lines
# ================================================
qsHardeningDisaStigOwnerships() {
    # Dump the intro line
    dumpInfoLine 'Hardening DISA STIG file ownerships'

    # Do the hardening
    [[ $(fileOrDirectoryExists /bin/csh) ]] && sudo chmod -f 0755 /bin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/jsh) ]] && sudo chmod -f 0755 /bin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/ksh) ]] && sudo chmod -f 0755 /bin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/rsh) ]] && sudo chmod -f 0755 /bin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/sh) ]] && sudo chmod -f 0755 /bin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/kmem) ]] && sudo chmod -f 0640 /dev/kmem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/kmem) ]] && sudo chown -f root:sys /dev/kmem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/mem) ]] && sudo chmod -f 0640 /dev/mem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/mem) ]] && sudo chown -f root:sys /dev/mem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/null) ]] && sudo chmod -f 0666 /dev/null >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/null) ]] && sudo chown -f root:sys /dev/null >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh) ]] && sudo chmod -f 0755 /etc/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/jsh) ]] && sudo chmod -f 0755 /etc/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ksh) ]] && sudo chmod -f 0755 /etc/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rsh) ]] && sudo chmod -f 0755 /etc/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sh) ]] && sudo chmod -f 0755 /etc/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/aliases) ]] && sudo chmod -f 0644 /etc/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/aliases) ]] && sudo chown -f root:root /etc/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/exports) ]] && sudo chmod -f 0640 /etc/exports >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/exports) ]] && sudo chown -f root:root /etc/exports >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ftpusers) ]] && sudo chmod -f 0640 /etc/ftpusers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ftpusers) ]] && sudo chown -f root:root /etc/ftpusers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/host.lpd) ]] && sudo chmod -f 0664 /etc/host.lpd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inetd.conf) ]] && sudo chmod -f 0440 /etc/inetd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inetd.conf) ]] && sudo chown -f root:root /etc/inetd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/aliases) ]] && sudo chmod -f 0644 /etc/mail/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/aliases) ]] && sudo chown -f root:root /etc/mail/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/passwd) ]] && sudo chmod -f 0644 /etc/passwd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/passwd) ]] && sudo chown -f root:root /etc/passwd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shadow) ]] && sudo chmod -f 0400 /etc/shadow >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shadow) ]] && sudo chown -f root:root /etc/shadow >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.cmds) ]] && sudo chmod -f 0600 /etc/uucp/L.cmds >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.cmds) ]] && sudo chown -f uucp:uucp /etc/uucp/L.cmds >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.sys) ]] && sudo chmod -f 0600 /etc/uucp/L.sys >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.sys) ]] && sudo chown -f uucp:uucp /etc/uucp/L.sys >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/Permissions) ]] && sudo chmod -f 0600 /etc/uucp/Permissions >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/Permissions) ]] && sudo chown -f uucp:uucp /etc/uucp/Permissions >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.unknown) ]] && sudo chmod -f 0600 /etc/uucp/remote.unknown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.unknown) ]] && sudo chown -f root:root /etc/uucp/remote.unknown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.systems) ]] && sudo chmod -f 0600 /etc/uucp/remote.systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uccp/Systems) ]] && sudo chmod -f 0600 /etc/uccp/Systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uccp/Systems) ]] && sudo chown -f uucp:uucp /etc/uccp/Systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/csh) ]] && sudo chmod -f 0755 /sbin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/jsh) ]] && sudo chmod -f 0755 /sbin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ksh) ]] && sudo chmod -f 0755 /sbin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/rsh) ]] && sudo chmod -f 0755 /sbin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/sh) ]] && sudo chmod -f 0755 /sbin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/csh) ]] && sudo chmod -f 0755 /usr/bin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/jsh) ]] && sudo chmod -f 0755 /usr/bin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ksh) ]] && sudo chmod -f 0755 /usr/bin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rsh) ]] && sudo chmod -f 0755 /usr/bin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/sh) ]] && sudo chmod -f 0755 /usr/bin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/mail) ]] && sudo chmod -f 1777 /var/mail >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/spool/uucppublic) ]] && sudo chmod -f 1777 /var/spool/uucppublic >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening .ssh
#
# @usage
# qsHardeningSsh
#
# @info
# Dumps info lines
# ================================================
qsHardeningSsh() {
    # Dump the intro line
    dumpInfoLine 'Hardening .ssh folders'

    # Get the users
    local -A users
    getAllUsersAndHome users

    #Set all files in ``.ssh`` to ``600``
    local user
    for user in "${!users[@]}"
    do
        local tmpPath=${users[${user}]}
        if [[ $(fileOrDirectoryExists ${tmpPath}/.ssh) ]]
        then
            dumpInfoLine "... for user '${user}'"
            sudo chmod 700 ${tmpPath}/.ssh >/dev/null 2>&1
            sudo chmod 600 ${tmpPath}/.ssh/* >/dev/null 2>&1
        fi
    done

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
