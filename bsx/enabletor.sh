#!/bin/bash

# Colors
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

# Detect Operating system
INSTALL=""
UPDATE=""
INIT_TOR="sudo systemctl restart tor"
detect_os_arch() {
    if type -P apt > /dev/null; then
        # Debian / Ubuntu / Mint
        INSTALL="sudo apt install -y"
        UPDATE="sudo apt update"
        $green"\nDetected Debian\n";$nocolor
    elif type -P dnf > /dev/null; then
        # Fedora
        INSTALL="sudo dnf install -y"
        UPDATE="sudo dnf check-update"
        $green"\nDetected Fedora\n";$nocolor
    elif type -P pacman > /dev/null; then
        # Arch Linux
        INSTALL="sudo pacman -S"
        UPDATE="sudo pacman -Syu"
        $green"\nDetected Arch Linux\n";$nocolor
    elif type -P brew > /dev/null; then
        # MacOS
        INSTALL="brew install"
        $green"\nDetected MacOS\n";$nocolor
    else
        $red"Failed to detect OS. Unsupported or unknown distribution.\nInstall Failed.";$nocolor
        exit
    fi
}

detect_os_arch

# Check for Tor installation
if type -P tor > /dev/null; then
	echo -e "\nTor is already installed :)"
else
	# Install and configure tor
	echo "Installing Tor..."
	$UPDATE
	$INSTALL tor
fi

# Create HashesControlPassword
echo -e "In the next step you'll choose a password. NOTE: It will be saved in PLAIN TEXT."
read -p "Enter a (new) tor control password [example: 123123] " torcontrolpass
# Edit /etc/tor/torrc
torhashedpass=$(tor --hash-password $torcontrolpass)
enabledcontrol=$(echo "ControlPort 9051")
skipcontrol=$(grep -x "$enabledcontrol" /etc/tor/torrc)
if [[ $skipcontrol ]]; then
	# Use Existing enabled ControlPort and append HashedControlPassword
	echo -e "# Added by basicswap-bash\nHashedControlPassword $torhashedpass" | sudo tee -a /etc/tor/torrc
else
	echo -e "# Added by basicswap-bash\n$enabledcontrol\nHashedControlPassword $torhashedpass" | sudo tee -a /etc/tor/torrc
fi

# Restart tor to apply
$INIT_TOR
echo "Waiting for Tor... 5sec" && sleep 5

# lol are we there yet?
TOR_PROXY_HOST=127.0.0.1
basicswap-prepare --datadir=$SWAP_DATADIR --enabletor

# Workaround: Replace torpassword in various config files
oldtorpass=$(cat $SWAP_DATADIR/basicswap.json | jq -r .tor_control_password)
sed -i "s/$oldtorpass/$torcontrolpass/" $SWAP_DATADIR/*/*.conf $SWAP_DATADIR/basicswap.json
# Fix: localhost binding for btc/ltc/part (etc) configs
sed -i -z "s/\nbind=0.0.0.0/\nbind=127.0.0.1/" $SWAP_DATADIR/*/*.conf
