#!/bin/bash

# ================================================
# Global settings
# ================================================

# Defines if it is the local environment (needed for not moving the script)
isDevelopment=false

# Defines if it is the master server
isMasterServer=false

# The available options
availableOptions['--sudopw:']='Option to set the sudo password'
availableOptions['-i | --init']='If set, only the config will be created, but no setup will be started'
availableOptions['-d | --debug']='If set, debugging will be enabled'
availableOptions['-c | --continue']='If set, the continue pauses will be skipped'
availableOptions['-f | --force']='If set, only required will be asked by this script'

# The default user password
defaultUserPassword='default'

# The default users and public keys
defaultUsers['username']='public_key'

# The default users and groups [comma separated]
defaultUsersAndGroups['username']='packages,sudoers'

# The rollout server ip
rolloutServerIP=''
rolloutServerDnsName=''
rolloutTestUrl=''

# The node server ip's
#nodeServerIps['1']=''

# The git credentials
gitCredentials=''

# The clear cache projects
declare -g -A clearCacheProjects
#clearCacheProjects['name']='/var/www/html/...'
