#!/bin/bash

# ================================================
# A security/hardening script
# ================================================

# ================================================
# Quick secure
#
# Inspired by
# @link https://github.com/marshyski/quick-secure/
# @link https://github.com/marshyski/quick-secure/blob/master/quick-secure
# ================================================
quickSecure() {
    # ================================================
    # Set variables of script
    # ================================================
    PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/local/bin:/opt/local/sbin"
    PASS_EXP="60" #used to set password expire in days
    PASS_WARN="14" #used to set password warning in days
    PASS_CHANG="1" #used to set how often you can change password in days
    SELINUX=`grep ^SELINUX= /etc/selinux/config 2>/dev/null | awk -F'=' '{ print $2 }'`

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
    # Turn off enforcing before setting configurations
    # ================================================
    if [[ `getenforce 2>/dev/null` = 'Enforcing' ]]
    then
        setenforce 0
        dumpInfoLine 'Turned of enforcing'
    fi

    # ================================================
    # Turn off selinux before setting configurations
    # ================================================
    if [[ -f /etc/sysconfig/selinux ]]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        echo 'SELINUX=disabled' > /etc/sysconfig/selinux
        echo 'SELINUXTYPE=targeted' >> /etc/sysconfig/selinux
        chmod -f 0640 /etc/sysconfig/selinux
        dumpInfoLine 'Turned of Selinux'
    fi

    # ================================================
    # Cron setup
    # ================================================
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
    [[ -d /etc/cron.monthly ]] && sudo chmod -f 0700 /etc/cron.monthly
    [[ -d /etc/cron.weekly ]] && sudo chmod -f 0700 /etc/cron.weekly
    [[ -d /etc/cron.daily ]] && sudo chmod -f 0700 /etc/cron.daily
    [[ -d /etc/cron.hourly ]] && sudo chmod -f 0700 /etc/cron.hourly
    [[ -d /var/spool/cron ]] && sudo chmod -f 0700 /var/spool/cron
    [[ -d /var/spool/at ]] && sudo chmod -f 0700 /var/spool/at
    dumpInfoLine "... ${BGre}done${RCol}"

    # Changemod for the cron files
    dumpInfoLine 'Changing permissions of the cron files'
#    [[ -d /etc/cron.monthly ]] && [[ "$(sudo ls -A /etc/cron.monthly)" ]] && sudo chmod -f 0700 /etc/cron.monthly/*
#    [[ -d /etc/cron.weekly ]] && [[ "$(sudo ls -A /etc/cron.weekly)" ]] && sudo chmod -f 0700 /etc/cron.weekly/*
#    [[ -d /etc/cron.daily ]] && [[ "$(sudo ls -A /etc/cron.daily)" ]] && sudo chmod -f 0700 /etc/cron.daily/*
#    [[ -d /etc/cron.hourly ]] && [[ "$(sudo ls -A /etc/cron.hourly)" ]] && sudo chmod -f 0700 /etc/cron.hourly/*
#    [[ -d /var/spool/cron ]] && [[ "$(sudo ls -A /var/spool/cron/)" ]] && sudo chmod -f 0600 /var/spool/cron/*
#    [[ -d /var/spool/at ]] && [[ "$(sudo ls -A /var/spool/at/)" ]] && sudo chmod -f 0600 /var/spool/at/*
#    [[ -d /etc/cron.d ]] && [[ "$(sudo ls -A /etc/cron.d)" ]] && sudo chmod -f 0700 /etc/cron.d/*
    [[ -f /etc/cron.allow ]] && sudo chmod -f 0400 /etc/cron.allow
    [[ -f /etc/cron.deny ]] && sudo chmod -f 0400 /etc/cron.deny
    [[ -f /etc/crontab ]] && sudo chmod -f 0400 /etc/crontab
    [[ -f /etc/cron.allow ]] && sudo chmod -f 0400 /etc/at.allow
    [[ -f /etc/cron.deny ]] && sudo chmod -f 0400 /etc/at.deny
    [[ -f /etc/anacrontab ]] && sudo chmod -f 0400 /etc/anacrontab
    dumpInfoLine "... ${BGre}done${RCol}"


    echo 'hier'
    exitScript
}