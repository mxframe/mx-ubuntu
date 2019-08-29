#!/bin/bash

# ================================================
# Global settings
# ================================================

# Defines if it is the local environment (needed for not moving the script)
isDevelopment=false

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
