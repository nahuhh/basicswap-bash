#!/bin/bash

# Set working directory
export SWAP_DATADIR=$HOME/coinswaps

# Colors
red="printf \e[31;1m"
green="printf \e[32;1m"
nocolor="printf \e[0m"

# Coins
coins=$(
    cat <<- EOF

	bitcoin
	bitcoincash
	dash
	decred
	dogecoin
	firo
	litecoin
	monero
	namecoin
	pivx
	wownero

	EOF
)

# Activate venv
activate_venv() {
    source $SWAP_DATADIR/venv/bin/activate
}

# Check if basicswap is running
is_running() {
    if [[ -f $SWAP_DATADIR/particl/particl.pid ]]; then
        bsx_pid=$(cat $SWAP_DATADIR/particl/particl.pid)
        if [[ $bsx_pid ]]; then
            bsx_run=$(pgrep particld | grep $bsx_pid)
            if [[ ! $bsx_run ]]; then
                $red"\nError: BasicSwapDEX is running.\n"
                $nocolor
                exit
            fi
        fi
    fi
}

is_encrypted() {
    printf "BasicSwapDEX is currently:\n[1] Encrypted\n[2] Unencrypted\n\n"
    $red"Note: this is a password that you setup via the GUI.\n"
    $red"This is NOT the clientauth password\n\n"
    $nocolor
    until [[ "$l" =~ ^[12]$ ]]; do
        read -p 'Select an option [1|2]: ' l
        case $l in
            1)
                until [[ $pass1 ]] && [[ $pass1 == $pass2 ]]; do
                    read -sp 'Enter your BasicSwap password: ' pass1
                    read -sp $'\nRe-enter your BasicSwap password: ' pass2
                    if [[ $pass1 == $pass2 ]]; then
                        export WALLET_ENCRYPTION_PWD=$pass1
                    else
                        $red"\nThe passwords entered don't match. Try again\n\n"
                        $nocolor
                    fi
                done
                ;;
            2)
                $nocolor"\nProceeding without a password\n"
                ;;
            *)
                $red"You must answer 1 or 2\n"
                $nocolor
                ;;
        esac
    done
}

# Check Tails
is_tails() {
    if [[ $USER == amnesia ]]; then
        export SWAP_DATADIR=$HOME/Persistent/coinswaps
        export TAILS=1
    fi
}

# Detect OS
detect_os_arch() {
    if [[ $(uname -s) = "Darwin" ]]; then
        # MacOS
        export MACOS=1
        if type -p brew > /dev/null; then
            $green"Homebrew is installed\n"
            $nc
            INSTALL="brew install"
        else
            $green"Installing Homebrew\n"
            $nc
            INSTALL="curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash && brew install"
        fi
        DEPENDENCY="python gnupg pkg-config"
        INIT_TOR="pkill tor && tor"
        $green"\n\nDetected MacOS"
        $nocolor
    elif type -p apt > /dev/null; then
        if [[ $USER == amnesia ]]; then
            $green"\n\nDetected Tails"
            $nocolor
        else
            $green"\n\nDetected Debian"
            $nocolor
        fi
        # Debian / Ubuntu / Mint
        INSTALL="sudo apt install"
        UPDATE="sudo apt update"
        DEPENDENCY="python3-pip python3-venv gnupg pkg-config"
        INIT_TOR=$SYSTEMD_TOR
    elif type -p dnf > /dev/null; then
        # Fedora
        INSTALL="sudo dnf install"
        UPDATE="sudo dnf check-update"
        DEPENDENCY="python3-virtualenv python3-pip python3-devel gnupg2 pkgconf"
        INIT_TOR=$SYSTEMD_TOR
        $green"\n\nDetected Fedora"
        $nocolor
    elif type -p pacman > /dev/null; then
        # Arch Linux
        INSTALL="sudo pacman -S"
        UPDATE="sudo pacman -Syu"
        DEPENDENCY="curl python-pipenv gnupg pkgconf base-devel"
        INIT_TOR=$SYSTEMD_TOR
        $green"\n\nDetected Arch Linux"
        $nocolor
    else
        $red"\nFailed to detect OS. Unsupported or unknown distribution.\nInstall Failed.\n"
        $nocolor
        exit
    fi
}
