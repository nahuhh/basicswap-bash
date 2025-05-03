#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

# Detect Operating system
INSTALL=""
UPDATE=""
INIT_TOR=""
SYSTEMD_TOR="sudo systemctl restart tor"

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

# Create HashedControlPassword
torcontrolpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
# Edit /etc/tor/torrc
torhashedpass=$(tor --hash-password $torcontrolpass)
enabledcontrol=$(echo "ControlPort 9051")
skipcontrol=$(sudo grep -x "$enabledcontrol" /etc/tor/torrc)
echo "Check torrc for enabled ControlPort"
if [[ $skipcontrol ]]; then
    # Use Existing enabled ControlPort and append HashedControlPassword
    printf "# Added by basicswap-bash\nHashedControlPassword $torhashedpass\n" | sudo tee -a /etc/tor/torrc
else
    printf "# Added by basicswap-bash\n$enabledcontrol\nHashedControlPassword $torhashedpass\n" | sudo tee -a /etc/tor/torrc
fi

# Restart tor to apply
$INIT_TOR

BSX_LOCAL_TOR=true basicswap-prepare --datadir=$SWAP_DATADIR --enabletor

# Workaround: Replace torpassword in various config files
oldtorpass=$(cat $SWAP_DATADIR/basicswap.json | jq -r .tor_control_password)
sed -i "s/$oldtorpass/$torcontrolpass/" $SWAP_DATADIR/*/*.conf $SWAP_DATADIR/basicswap.json
