#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

# Detect Operating system
INSTALL=""
UPDATE=""

detect_os_arch

# Check for Tor installation
if type -p tor > /dev/null; then
    printf "\nTor is already installed :)\n"
else
    # Install and configure tor
    echo "Installing Tor..."
    $UPDATE
    $INSTALL tor
fi

# Enable tor bsx
basicswap-prepare --datadir=$SWAP_DATADIR --enabletor

# Restart tor
stop_tor && start_tor
