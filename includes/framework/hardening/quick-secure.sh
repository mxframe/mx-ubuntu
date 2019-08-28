#!/bin/bash

# ================================================
# Set variables of script
# ================================================
#PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/local/bin:/opt/local/sbin"

# ================================================
# Quick secure
#
# Inspired by
# https://github.com/marshyski/quick-secure/
# https://github.com/marshyski/quick-secure/blob/master/quick-secure
# ================================================
hardeningWithQuickSecure() {
    # ================================================
    # Print the info header
    # ================================================
    dumpInfoHeader 'Hardening with quick secure'

    # ================================================
    # Call the necessary functions
    # ================================================
    qsHardeningCron
    qsHardeningClamAV
    qsHardeningOwnerships
    qsHardeningDisaStigOwnerships
    qsHardeningSsh
    qsHardeningRelatedPackages
    qsHardeningUsers
    qsHardeningPamFingerprint
    qsHardeningChkConfigLevels
    qsHardeningMiscSettingsAndPermissions
    qsHardeningSshRootLogin
    qsHardeningHomeDirectories
    qsHardeningKernelParameters
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
    [[ $(fileOrDirectoryExists /tmp) = true ]] && sudo chmod -f 1777 /tmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/crash) = true ]] && sudo chown -f root:root /var/crash >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/cache/mod_proxy) = true ]] && sudo chown -f root:root /var/cache/mod_proxy >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/lib/dav) = true ]] && sudo chown -f root:root /var/lib/dav >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/lockfile) = true ]] && sudo chown -f root:root /usr/bin/lockfile >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/lib/nfs/statd) = true ]] && sudo chown -f rpcuser:rpcuser /var/lib/nfs/statd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/adm) = true ]] && sudo chown -f adm:adm /var/adm >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/crash) = true ]] && sudo chmod -f 0600 /var/crash >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/mail) = true ]] && sudo chown -f root:root /bin/mail >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/reboot) = true ]] && sudo chmod -f 0700 /sbin/reboot >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/shutdown) = true ]] && sudo chmod -f 0700 /sbin/shutdown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ssh/ssh*config) = true ]] && sudo chmod -f 0600 /etc/ssh/ssh*config >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /root) = true ]] && sudo chown -f root:root /root >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /root) = true ]] && sudo chmod -f 0700 /root >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ypcat) = true ]] && sudo chmod -f 0500 /usr/bin/ypcat >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/sbin/usernetctl) = true ]] && sudo chmod -f 0700 /usr/sbin/usernetctl >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rlogin) = true ]] && sudo chmod -f 0700 /usr/bin/rlogin >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rcp) = true ]] && sudo chmod -f 0700 /usr/bin/rcp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/pam.d) = true ]] && sudo chmod -f 0640 /etc/pam.d/system-auth* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/login.defs) = true ]] && sudo chmod -f 0640 /etc/login.defs >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security) = true ]] && sudo chmod -f 0750 /etc/security >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ausearch) = true ]] && sudo chmod -f 0750 /sbin/ausearch >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ausearch) = true ]] && sudo chown -f root /sbin/ausearch >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/aureport) = true ]] && sudo chown -f root /sbin/aureport >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/aureport) = true ]] && sudo chmod -f 0750 /sbin/aureport >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/autrace) = true ]] && sudo chown -f root /sbin/autrace >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/autrace) = true ]] && sudo chmod -f 0750 /sbin/autrace >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/audispd) = true ]] && sudo chown -f root /sbin/audispd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/audispd) = true ]] && sudo chmod -f 0750 /sbin/audispd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/bashrc) = true ]] && sudo chmod -f 0444 /etc/bashrc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh.cshrc) = true ]] && sudo chmod -f 0444 /etc/csh.cshrc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh.login) = true ]] && sudo chmod -f 0444 /etc/csh.login >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/client.conf) = true ]] && sudo chmod -f 0600 /etc/cups/client.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/cupsd.conf) = true ]] && sudo chmod -f 0600 /etc/cups/cupsd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/client.conf) = true ]] && sudo chown -f root:sys /etc/cups/client.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/cups/cupsd.conf) = true ]] && sudo chown -f root:sys /etc/cups/cupsd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/grub.conf) = true ]] && sudo chmod -f 0600 /etc/grub.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/grub.conf) = true ]] && sudo chown -f root:root /etc/grub.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub2/grub.cfg) = true ]] && sudo chmod -f 0600 /boot/grub2/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub2/grub.cfg) = true ]] && sudo chown -f root:root /boot/grub2/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub/grub.cfg) = true ]] && sudo chmod -f 0600 /boot/grub/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /boot/grub/grub.cfg) = true ]] && sudo chown -f root:root /boot/grub/grub.cfg >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/hosts) = true ]] && sudo chmod -f 0444 /etc/hosts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/hosts) = true ]] && sudo chown -f root:root /etc/hosts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inittab) = true ]] && sudo chmod -f 0600 /etc/inittab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inittab) = true ]] && sudo chown -f root:root /etc/inittab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/sendmail.cf) = true ]] && sudo chmod -f 0444 /etc/mail/sendmail.cf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/sendmail.cf) = true ]] && sudo chown -f root:bin /etc/mail/sendmail.cf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ntp.conf) = true ]] && sudo chmod -f 0600 /etc/ntp.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/access.conf) = true ]] && sudo chmod -f 0640 /etc/security/access.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/console.perms) = true ]] && sudo chmod -f 0600 /etc/security/console.perms >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/console.perms.d/50-default.perms) = true ]] && sudo chmod -f 0600 /etc/security/console.perms.d/50-default.perms >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/limits) = true ]] && sudo chmod -f 0600 /etc/security/limits >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/services) = true ]] && sudo chmod -f 0444 /etc/services >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shells) = true ]] && sudo chmod -f 0444 /etc/shells >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sudoers) = true ]] && sudo chmod -f 0440 /etc/sudoers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sudoers) = true ]] && sudo chown -f root:root /etc/sudoers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.conf) = true ]] && sudo chmod -f 0600 /etc/sysctl.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.conf) = true ]] && sudo chown -f root:root /etc/sysctl.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) = true ]] && sudo chown -f root:root /etc/sysctl.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) = true ]] && sudo chmod -f 0700 /etc/sysctl.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sysctl.d) = true ]] && sudo chmod -f 0600 /etc/sysctl.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/syslog.conf) = true ]] && sudo chmod -f 0600 /etc/syslog.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/yp/binding) = true ]] && sudo chmod -f 0600 /var/yp/binding >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) = true ]] && sudo chmod -Rf 0640 /var/log/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) = true ]] && sudo chmod -f 0755 /var/log >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/syslog) = true ]] && sudo chmod -f 0750 /var/log/syslog >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) = true ]] && sudo chmod -f 0600 /var/log/lastlog* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log) = true ]] && sudo chmod -f 0600 /var/log/cron* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/btmp) = true ]] && sudo chmod -f 0600 /var/log/btmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/log/wtmp) = true ]] && sudo chmod -f 0660 /var/log/wtmp >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/profile) = true ]] && sudo chmod -f 0444 /etc/profile >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rc.d/rc.local) = true ]] && sudo chmod -f 0700 /etc/rc.d/rc.local >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/securetty) = true ]] && sudo chmod -f 0400 /etc/securetty >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rc.local) = true ]] && sudo chmod -f 0700 /etc/rc.local >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/wall) = true ]] && sudo chmod -f 0750 /usr/bin/wall >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/wall) = true ]] && sudo chown -f root:tty /usr/bin/wall >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /mnt) = true ]] && sudo chown -f root:users /mnt >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /media) = true ]] && sudo chown -f root:users /media >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/.login) = true ]] && sudo chmod -f 0644 /etc/.login >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/profile.d) = true ]] && sudo chmod -f 0644 /etc/profile.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/security/environ) = true ]] && sudo chown -f root /etc/security/environ >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) = true ]] && sudo chown -f root /etc/xinetd.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) = true ]] && sudo chown -f root /etc/xinetd.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) = true ]] && sudo chmod -f 0750 /etc/xinetd.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/xinetd.d) = true ]] && sudo chmod -f 0640 /etc/xinetd.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/selinux/config) = true ]] && sudo chmod -f 0640 /etc/selinux/config >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/chfn) = true ]] && sudo chmod -f 0750 /usr/bin/chfn >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/chsh) = true ]] && sudo chmod -f 0750 /usr/bin/chsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/write) = true ]] && sudo chmod -f 0750 /usr/bin/write >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/mount.nfs) = true ]] && sudo chmod -f 0750 /sbin/mount.nfs >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/mount.nfs4) = true ]] && sudo chmod -f 0750 /sbin/mount.nfs4 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ldd) = true ]] && sudo chmod -f 0700 /usr/bin/ldd >/dev/null 2>&1 # 0400 for some systems
    [[ $(fileOrDirectoryExists /bin/traceroute) = true ]] && sudo chmod -f 0700 /bin/traceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/traceroute) = true ]] && sudo chown -f root:root /bin/traceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/) = true ]] && sudo chmod -f 0700 /usr/bin/traceroute6* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/traceroute6) = true ]] && sudo chown -f root:root /usr/bin/traceroute6 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/tcptraceroute) = true ]] && sudo chmod -f 0700 /bin/tcptraceroute >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/iptunnel) = true ]] && sudo chmod -f 0700 /sbin/iptunnel >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/) = true ]] && sudo chmod -f 0700 /usr/bin/tracpath* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/audio) = true ]] && sudo chmod -f 0644 /dev/audio >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/audio) = true ]] && sudo chown -f root:root /dev/audio >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/environment) = true ]] && sudo chmod -f 0644 /etc/environment >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/environment) = true ]] && sudo chown -f root:root /etc/environment >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.conf) = true ]] && sudo chmod -f 0600 /etc/modprobe.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.conf) = true ]] && sudo chown -f root:root /etc/modprobe.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) = true ]] && sudo chown -f root:root /etc/modprobe.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) = true ]] && sudo chown -f root:root /etc/modprobe.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) = true ]] && sudo chmod -f 0700 /etc/modprobe.d >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/modprobe.d) = true ]] && sudo chmod -f 0600 /etc/modprobe.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /selinux) = true ]] && sudo chmod -f o-w /selinux/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc) = true ]] && sudo chmod -f 0755 /etc >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man1) = true ]] && sudo chmod -f 0644 /usr/share/man/man1/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man5) = true ]] && sudo chmod -Rf 0644 /usr/share/man/man5 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/share/man/man1) = true ]] && sudo chmod -Rf 0644 /usr/share/man/man1 >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/yum.repos.d) = true ]] && sudo chmod -f 0600 /etc/yum.repos.d/* >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/fstab) = true ]] && sudo chmod -f 0640 /etc/fstab >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/cache/man) = true ]] && sudo chmod -f 0755 /var/cache/man >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/init.d/atd) = true ]] && sudo chmod -f 0755 /etc/init.d/atd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ppp/peers) = true ]] && sudo chmod -f 0750 /etc/ppp/peers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/ntfs-3g) = true ]] && sudo chmod -f 0755 /bin/ntfs-3g >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/sbin/pppd) = true ]] && sudo chmod -f 0750 /usr/sbin/pppd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/chatscripts) = true ]] && sudo chmod -f 0750 /etc/chatscripts >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/local/share/ca-certificates) = true ]] && sudo chmod -f 0750 /usr/local/share/ca-certificates >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
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
    [[ $(fileOrDirectoryExists /bin/csh) = true ]] && sudo chmod -f 0755 /bin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/jsh) = true ]] && sudo chmod -f 0755 /bin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/ksh) = true ]] && sudo chmod -f 0755 /bin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/rsh) = true ]] && sudo chmod -f 0755 /bin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /bin/sh) = true ]] && sudo chmod -f 0755 /bin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/kmem) = true ]] && sudo chmod -f 0640 /dev/kmem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/kmem) = true ]] && sudo chown -f root:sys /dev/kmem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/mem) = true ]] && sudo chmod -f 0640 /dev/mem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/mem) = true ]] && sudo chown -f root:sys /dev/mem >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/null) = true ]] && sudo chmod -f 0666 /dev/null >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /dev/null) = true ]] && sudo chown -f root:sys /dev/null >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/csh) = true ]] && sudo chmod -f 0755 /etc/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/jsh) = true ]] && sudo chmod -f 0755 /etc/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ksh) = true ]] && sudo chmod -f 0755 /etc/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/rsh) = true ]] && sudo chmod -f 0755 /etc/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/sh) = true ]] && sudo chmod -f 0755 /etc/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/aliases) = true ]] && sudo chmod -f 0644 /etc/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/aliases) = true ]] && sudo chown -f root:root /etc/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/exports) = true ]] && sudo chmod -f 0640 /etc/exports >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/exports) = true ]] && sudo chown -f root:root /etc/exports >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ftpusers) = true ]] && sudo chmod -f 0640 /etc/ftpusers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/ftpusers) = true ]] && sudo chown -f root:root /etc/ftpusers >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/host.lpd) = true ]] && sudo chmod -f 0664 /etc/host.lpd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inetd.conf) = true ]] && sudo chmod -f 0440 /etc/inetd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/inetd.conf) = true ]] && sudo chown -f root:root /etc/inetd.conf >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/aliases) = true ]] && sudo chmod -f 0644 /etc/mail/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/mail/aliases) = true ]] && sudo chown -f root:root /etc/mail/aliases >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/passwd) = true ]] && sudo chmod -f 0644 /etc/passwd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/passwd) = true ]] && sudo chown -f root:root /etc/passwd >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shadow) = true ]] && sudo chmod -f 0400 /etc/shadow >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/shadow) = true ]] && sudo chown -f root:root /etc/shadow >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.cmds) = true ]] && sudo chmod -f 0600 /etc/uucp/L.cmds >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.cmds) = true ]] && sudo chown -f uucp:uucp /etc/uucp/L.cmds >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.sys) = true ]] && sudo chmod -f 0600 /etc/uucp/L.sys >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/L.sys) = true ]] && sudo chown -f uucp:uucp /etc/uucp/L.sys >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/Permissions) = true ]] && sudo chmod -f 0600 /etc/uucp/Permissions >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/Permissions) = true ]] && sudo chown -f uucp:uucp /etc/uucp/Permissions >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.unknown) = true ]] && sudo chmod -f 0600 /etc/uucp/remote.unknown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.unknown) = true ]] && sudo chown -f root:root /etc/uucp/remote.unknown >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uucp/remote.systems) = true ]] && sudo chmod -f 0600 /etc/uucp/remote.systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uccp/Systems) = true ]] && sudo chmod -f 0600 /etc/uccp/Systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /etc/uccp/Systems) = true ]] && sudo chown -f uucp:uucp /etc/uccp/Systems >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/csh) = true ]] && sudo chmod -f 0755 /sbin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/jsh) = true ]] && sudo chmod -f 0755 /sbin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/ksh) = true ]] && sudo chmod -f 0755 /sbin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/rsh) = true ]] && sudo chmod -f 0755 /sbin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /sbin/sh) = true ]] && sudo chmod -f 0755 /sbin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/csh) = true ]] && sudo chmod -f 0755 /usr/bin/csh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/jsh) = true ]] && sudo chmod -f 0755 /usr/bin/jsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/ksh) = true ]] && sudo chmod -f 0755 /usr/bin/ksh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/rsh) = true ]] && sudo chmod -f 0755 /usr/bin/rsh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /usr/bin/sh) = true ]] && sudo chmod -f 0755 /usr/bin/sh >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/mail) = true ]] && sudo chmod -f 1777 /var/mail >/dev/null 2>&1
    [[ $(fileOrDirectoryExists /var/spool/uucppublic) = true ]] && sudo chmod -f 1777 /var/spool/uucppublic >/dev/null 2>&1

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
        if [[ -d ${tmpPath}/.ssh ]]
        then
            dumpInfoLine "... for user '${user}'"
            sudo chmod 700 ${tmpPath}/.ssh >/dev/null 2>&1
            sudo chmod 600 ${tmpPath}/.ssh/* >/dev/null 2>&1
        fi
    done

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening related packages
#
# @usage
# qsHardeningRelatedPackages
#
# @info
# Dumps info lines
#
# https://askubuntu.com/questions/258219/how-do-i-make-apt-get-install-less-noisy
# ================================================
qsHardeningRelatedPackages() {
    # Dump the intro line
    dumpInfoLine 'Hardening related packages'

    # Remove security related packages
    if [[ `which apt-get 2>/dev/null` != '' ]]
    then
        sudo apt-get -q -qq autoremove -y vsftpd 2>/dev/null
        sudo apt-get -q -qq autoremove -y nmap 2>/dev/null
        sudo apt-get -q -qq autoremove -y telnetd 2>/dev/null
        sudo apt-get -q -qq autoremove -y rdate 2>/dev/null
        sudo apt-get -q -qq autoremove -y tcpdump 2>/dev/null
        sudo apt-get -q -qq autoremove -y vnc4server 2>/dev/null
        sudo apt-get -q -qq autoremove -y vino 2>/dev/null
        sudo apt-get -q -qq autoremove -y wireshark 2>/dev/null
        sudo apt-get -q -qq autoremove -y bind9-host 2>/dev/null
        sudo apt-get -q -qq autoremove -y libbind9-90 2>/dev/null
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening users (remove unnecessary)
#
# @usage
# qsHardeningUsers
#
# @info
# Dumps info lines
# ================================================
qsHardeningUsers() {
    # Dump the intro line
    dumpInfoLine 'Hardening users (remove unnecessary)'

    # Account management and cleanups
    if [[ `which userdel 2>/dev/null` != '' ]]
    then
        sudo userdel -f games 2>/dev/null
        sudo userdel -f news 2>/dev/null
        sudo userdel -f gopher 2>/dev/null
        sudo userdel -f tcpdump 2>/dev/null
        sudo userdel -f shutdown 2>/dev/null
        sudo userdel -f halt 2>/dev/null
        sudo userdel -f sync 2>/dev/null
        sudo userdel -f ftp 2>/dev/null
        sudo userdel -f operator 2>/dev/null
        sudo userdel -f lp 2>/dev/null
        sudo userdel -f uucp 2>/dev/null
        sudo userdel -f irc 2>/dev/null
        sudo userdel -f gnats 2>/dev/null
        sudo userdel -f pcap 2>/dev/null
        sudo userdel -f netdump 2>/dev/null
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening the pam fingerprint)
#
# @usage
# qsHardeningPamFingerprint
#
# @info
# Dumps info lines
# ================================================
qsHardeningPamFingerprint() {
    # Dump the intro line
    dumpInfoLine 'Hardening the pam fingerprint'

    # Disable fingerprint in PAM and authconfig
    if [[ `which authconfig 2>/dev/null` != '' ]]
    then
        sudo authconfig --disablefingerprint --update 2>/dev/null
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening start-up chkconfig levels set
#
# @usage
# qsHardeningPamFingerprint
#
# @info
# Dumps info lines
# ================================================
qsHardeningChkConfigLevels() {
    # Dump the intro line
    dumpInfoLine 'Hardening start-up chkconfig levels set'

    # Start-up chkconfig levels set
    if [[ -f /sbin/chkconfig ]]
    then
        /sbin/chkconfig isdn off 2>/dev/null
        /sbin/chkconfig bluetooth off 2>/dev/null
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening misc settings and permissions
#
# @usage
# qsHardeningMiscSettingsAndPermissions
#
# @info
# Dumps info lines
# ================================================
qsHardeningMiscSettingsAndPermissions() {
    # Dump the intro line
    dumpInfoLine 'Hardening misc settings and permissions'

    # Misc settings and permissions
    sudo chmod -Rf o-w /usr/local/src/* 2>/dev/null
    sudo rm -f /etc/security/console.perms 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Permit ssh login from root
#
# @usage
# qsHardeningSshRootLogin
#
# @info
# Dumps info lines
# ================================================
qsHardeningSshRootLogin() {
    # Dump the intro line
    dumpInfoLine 'Permit ssh login from root'

    # Misc settings and permissions
    local rootLogin='PermitRootLogin'
    local sshConfig='/etc/ssh/ssh_config'
    if [[ -f ${sshConfig?} ]]
    then
        if sudo grep -q ${rootLogin?} ${sshConfig?} 2>/dev/null
        then
            sudo sed -i 's/.*PermitRootLogin.*/\tPermitRootLogin no/g' ${sshConfig?} 2>/dev/null
        else
            echo -e '\tPermitRootLogin no' | sudo tee -a ${sshConfig?} 2>/dev/null
        fi
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening the home directories
#
# @usage
# qsHardeningHomeDirectories
#
# @info
# Dumps info lines
# ================================================
qsHardeningHomeDirectories() {
    # Dump the intro line
    dumpInfoLine 'Hardening the home directories'

    # Set home directories to 0700 permissions
    local tmpDir
    if [[ -d /home ]]
    then
        for tmpDir in `find /home -maxdepth 1 -mindepth 1 -type d`
        do
            if [[ ${tmpDir##*/} = 'all' ]]
            then
                sudo chmod -f 0770 ${tmpDir} 2>/dev/null
            else
                sudo chmod -f 0700 ${tmpDir} 2>/dev/null
            fi
        done
    fi
    if [[ -d /export/home ]]
    then
        for tmpDir in `find /export/home -maxdepth 1 -mindepth 1 -type d`
        do
            sudo chmod -f 0700 ${tmpDir} 2>/dev/null
        done
    fi

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Hardening the basic kernel parameters
#
# @usage
# qsHardeningKernelParameters
#
# @info
# Dumps info lines
# ================================================
qsHardeningKernelParameters() {
    # Dump the intro line
    dumpInfoLine 'Hardening the basic kernel parameters'

    # Set basic kernel parameters
    if [[ `which sysctl 2>/dev/null` != "" ]]; then
        # Turn on Exec Shield for RHEL systems
        sudo sysctl -qw kernel.exec-shield=1 2>/dev/null

        # Turn on ASLR Conservative Randomization
        sudo sysctl -qw kernel.randomize_va_space=1 2>/dev/null

        # Hide Kernel Pointers
        sudo sysctl -qw kernel.kptr_restrict=1 2>/dev/null

        # Allow reboot/poweroff, remount read-only, sync command
        sudo sysctl -qw kernel.sysrq=176 2>/dev/null

        # Restrict PTRACE for debugging
        sudo sysctl -qw kernel.yama.ptrace_scope=1 2>/dev/null

        # Hard and Soft Link Protection
        sudo sysctl -qw fs.protected_hardlinks=1 2>/dev/null
        sudo sysctl -qw fs.protected_symlinks=1 2>/dev/null

        # Enable TCP SYN Cookie Protection
        sudo sysctl -qw net.ipv4.tcp_syncookies=1 2>/dev/null

        # Disable IP Source Routing
        sudo sysctl -qw net.ipv4.conf.all.accept_source_route=0 2>/dev/null

        # Disable ICMP Redirect Acceptance
        sudo sysctl -qw net.ipv4.conf.all.accept_redirects=0 2>/dev/null
        sudo sysctl -qw net.ipv6.conf.all.accept_redirects=0 2>/dev/null
        sudo sysctl -qw net.ipv4.conf.all.send_redirects=0 2>/dev/null
        sudo sysctl -qw net.ipv6.conf.all.send_redirects=0 2>/dev/null

        # Enable IP Spoofing Protection
        sudo sysctl -qw net.ipv4.conf.all.rp_filter=1 2>/dev/null
        sudo sysctl -qw net.ipv4.conf.default.rp_filter=1 2>/dev/null

        # Enable Ignoring to ICMP Requests
        sudo sysctl -qw net.ipv4.icmp_echo_ignore_all=1 2>/dev/null

        # Enable Ignoring Broadcasts Request
        sudo sysctl -qw net.ipv4.icmp_echo_ignore_broadcasts=1 2>/dev/null

        # Enable Bad Error Message Protection
        sudo sysctl -qw net.ipv4.icmp_ignore_bogus_error_responses=1 2>/dev/null

        # Enable Logging of Spoofed Packets, Source Routed Packets, Redirect Packets
        sudo sysctl -qw net.ipv4.conf.all.log_martians=1 2>/dev/null
        sudo sysctl -qw net.ipv4.conf.default.log_martians=1 2>/dev/null

        # Read values again
        sudo sysctl -p 2>/dev/null
    fi


    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
