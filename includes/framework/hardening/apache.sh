#!/bin/bash

# ================================================
# Apache Server Hardening
# https://github.com/sagespidy/Apache2
# https://geekflare.com/apache-web-server-hardening-security/
# ================================================
hardeningApache() {
    # ================================================
    # Print the info header
    # ================================================
    dumpInfoHeader 'Hardening the Apache Server'

    # Check if apache is installed
    if [[ ! -d /etc/apache2 ]]
    then
        dumpInfoLine "... ${BRed}not installed${RCol}"
        return
    fi

    # ================================================
    # Call the necessary functions
    # ================================================
    apIncreaseKeepAliveTimeout
    apSecureApacheServer
    apStopClickJacking
    apStopDisplayingApacheVersion
    apShowServerTokenAsApache
    apDisableEtag
    apDisableTrace
    apEnableActualIpLogging

    # Change owner & permission
    sudo chown www-data:www-data /var/www/html
    sudo chgrp -R www-data /var/www/html
    sudo chmod -R 775 /var/www/html
    # https://askubuntu.com/questions/51951/set-default-group-for-user-when-they-create-new-files
#    sudo chgrp -R www-data /var/www/html
    sudo chmod -R g+s /var/www/html
#    sudo chown -R $(whoami) /var/www/html
}

# ================================================
# Increase KeepAliveTimeout
#
# @usage
# apIncreaseKeepAliveTimeout
#
# @info
# Dumps info lines
# ================================================
apIncreaseKeepAliveTimeout() {
    # Dump the intro line
    dumpInfoLine 'Increase KeepAliveTimeout'

    # Perform the hardening
    sudo sed -i 's/KeepAliveTimeout 5/KeepAliveTimeout 60/' /etc/apache2/apache2.conf 2>/dev/null

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Secure Apache Server
#
# @usage
# apSecureApacheServer
#
# @info
# Dumps info lines
# ================================================
apSecureApacheServer() {
    # Dump the intro line
    dumpInfoLine 'Secure Apache Server'

    # Perform the hardening
    echo 'Header set X-XSS-Protection "1; mode=block"' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1
    echo 'Header always set X-Content-Type-Options "nosniff"' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1
    echo 'Header always set Strict-Transport-Security "max-age=63072000;includeSubDomains"' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Stop Click Jacking
#
# @usage
# apStopClickJacking
#
# @info
# Dumps info lines
# ================================================
apStopClickJacking() {
    # Dump the intro line
    dumpInfoLine 'Stop Click Jacking'

    # Perform the hardening
    echo 'Header always append X-Frame-Options SAMEORIGIN' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Stop displaying Apache Version
#
# @usage
# apStopDisplayingApacheVersion
#
# @info
# Dumps info lines
# ================================================
apStopDisplayingApacheVersion() {
    # Dump the intro line
    dumpInfoLine 'Stop displaying Apache Version'

    # Perform the hardening
    echo 'ServerSignature Off' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Show Servertoken as Apache
#
# @usage
# apShowServerTokenAsApache
#
# @info
# Dumps info lines
# ================================================
apShowServerTokenAsApache() {
    # Dump the intro line
    dumpInfoLine 'Show Servertoken as Apache'

    # Perform the hardening
    echo 'ServerTokens Prod' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Disable Etag
#
# @usage
# apDisableEtag
#
# @info
# Dumps info lines
# ================================================
apDisableEtag() {
    # Dump the intro line
    dumpInfoLine 'Disable Etag'

    # Perform the hardening
    echo 'FileETag None' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Disable Trace
#
# @usage
# apDisableTrace
#
# @info
# Dumps info lines
# ================================================
apDisableTrace() {
    # Dump the intro line
    dumpInfoLine 'Disable Trace'

    # Perform the hardening
    echo 'TraceEnable off' | sudo tee -a /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# Enable actual Ip Logging
#
# @usage
# apEnableActualIpLogging
#
# @info
# Dumps info lines
# ================================================
apEnableActualIpLogging() {
    # Dump the intro line
    dumpInfoLine 'Enable actual Ip Logging'

    # Perform the hardening
    sudo sed -i 's/LogFormat "%h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/LogFormat "%{X-Forwarded-For}i %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/' /etc/apache2/apache2.conf >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}

# ================================================
# apReloadApache
#
# @usage
# apReloadApache
#
# @info
# Dumps info lines
# ================================================
apReloadApache() {
    # Dump the intro line
    dumpInfoLine 'apReloadApache'

    # Perform the hardening
    sudo service apache2 reload >/dev/null 2>&1

    # Dump the done line
    dumpInfoLine "... ${BGre}done${RCol}"
}
