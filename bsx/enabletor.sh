#!/bin/bash

# Colors
red="printf \e[31;1m"
green="printf \e[32;1m"
nocolor="printf \e[0m"

# Detect Operating system
INSTALL=""
UPDATE=""
INIT_TOR=""
SYSTEMD_TOR="sudo systemctl restart tor"

check_tails() {
        if [[ $USER == amnesia ]]; then
            $green"\n\nDetected Tails";$nocolor
            TAILS=1
        else
            $green"\n\nDetected Debian";$nocolor
        fi
}

detect_os_arch() {
    if [[ $(uname -s) = "Darwin" ]]; then
        # MacOS
        export MACOS=1
        if type -p brew > /dev/null; then
            $green"Homebrew is installed\n";$nc
            INSTALL="brew install"
        else
            $green"Installing Homebrew\n";$nc
            INSTALL="curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash && brew install"
        fi
	INIT_TOR="pkill tor && tor"
        $green"\n\nDetected MacOS";$nocolor
    elif type -p apt > /dev/null; then
        check_tails
        # Debian / Ubuntu / Mint
        INSTALL="sudo apt install"
        UPDATE="sudo apt update"
	INIT_TOR=$SYSTEMD_TOR
    elif type -p dnf > /dev/null; then
        # Fedora
        INSTALL="sudo dnf install"
        UPDATE="sudo dnf check-update"
	INIT_TOR=$SYSTEMD_TOR
        $green"\n\nDetected Fedora";$nocolor
    elif type -p pacman > /dev/null; then
        # Arch Linux
        INSTALL="sudo pacman -S"
        UPDATE="sudo pacman -Syu"
	INIT_TOR=$SYSTEMD_TOR
        $green"\n\nDetected Arch Linux";$nocolor
    else
        $red"\nFailed to detect OS. Unsupported or unknown distribution.\nInstall Failed.\n";$nocolor
        exit
    fi
}

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
