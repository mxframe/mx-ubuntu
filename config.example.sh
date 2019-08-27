#!/bin/bash

# ================================================
# Global settings
# ================================================

# Defines if it is the local environment (needed for not moving the script)
isDevelopment=false

# The available options
availableOptions['-d | --debug']+="If set, debugging will be enabled"
availableOptions['--sudopw:']+="Option to set the sudo password"
