#!/bin/bash

# Set working directory
export SWAP_DATADIR=$HOME/coinswaps

# tor variables
export TOR_PROXY_PORT=19050
export TOR_CONTROL_PORT=19051
export TOR_DNS_PORT=15353
export BSX_LOCAL_TOR=true          # sets host to 127.0.0.1
export BSX_ALLOW_ENV_OVERRIDE=true # required to change the ports

# Network
[[ "${1}${2}${3}${4}" == *"regtest"* ]] && export regtest="--regtest"

# Colors
red() { echo -e "\e[31;1m$*\e[0m"; }
green() { echo -e "\e[32;1m$*\e[0m"; }

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

# Coin map
if [[ -z "${MACOS}" ]]; then
    declare -A coin_map
    coin_map=(
        [bitcoin]="BTC"
        [bitcoincash]="BCH"
        [dash]="DASH"
        [decred]="DCR"
        [dogecoin]="DOGE"
        [firo]="FIRO"
        [litecoin]="LTC"
        [monero]="XMR"
        [namecoin]="NMC"
        [pivx]="PIVX"
        [wownero]="WOW"
    )
fi

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
            if [[ $bsx_run ]]; then
                red "\nError: BasicSwapDEX is running."
                exit
            fi
        fi
    fi
}

is_encrypted() {
    echo -e "BasicSwapDEX is currently:\n[1] Encrypted\n[2] Unencrypted\n"
    red "Note: This is a password that you setup via the GUI."
    red "Note: This is NOT the clientauth password\n"
    until [[ "$l" =~ ^[12]$ ]]; do
        read -p 'Select an option [1|2]: ' l
        case $l in
            1)
                until [[ $pass1 ]] && [[ $pass1 = $pass2 ]]; do
                    read -sp 'Enter your existing BasicSwap encryption password: ' pass1
                    read -sp $'\nRe-enter your BasicSwap encryption password: ' pass2
                    if [[ $pass1 = $pass2 ]]; then
                        export WALLET_ENCRYPTION_PWD=$pass1
                    else
                        red "\nThe passwords entered don't match. Try again\n"
                    fi
                done
                ;;
            2)
                echo -e "\nProceeding without a password"
                ;;
            *)
                red "You must answer 1 or 2"
                ;;
        esac
    done
}

# Start tor
start_tor() {
    use_tor=$(jq .use_tor $SWAP_DATADIR/basicswap.json)
    tor_config=$(jq .tor_proxy_port $SWAP_DATADIR/basicswap.json)
    if [[ ${use_tor} = true ]]; then
        [[ ${tor_config} -eq 9050 ]] && bsx-enabletor
        pid_file="$SWAP_DATADIR/tor/tor.pid"
        pid() { cat $pid_file; }
        check_tor() { [[ -f $pid_file ]] && pgrep tor | grep $(pid); }
        if [[ ! $(check_tor) ]]; then
            tor -f $SWAP_DATADIR/tor/torrc &> /dev/null &
            echo $! > $pid_file
            if [[ $(check_tor) ]]; then
                green "Started Tor $(pid)"
            else
                red "Failed to start tor\nCheck for a conflict on these PIDs\n$(pgrep tor)"
                exit 1
            fi
        else
            green "Tor running $(pid)"
        fi
    else
        echo "Tor disabled"
    fi
}

# Stop tor
stop_tor() {
    pid_file="$SWAP_DATADIR/tor/tor.pid"
    if [[ -f $pid_file ]]; then
        pid() { cat $pid_file; }
        check_tor() { pgrep tor | grep $(pid); }
        tries=0
        pkill -F ${pid_file}
        while [[ $(check_tor) ]]; do
            ((tries++))
            if [[ $tries -gt 5 ]]; then
                red "Failed to stop tor $(pid)"
                exit 0
            fi
            red "Stopping tor $(pid)"
            sleep 1
            if [[ ! $(check_tor) ]]; then
                echo "Tor stopped successfully $(pid)"
                exit 0
            fi
        done
        echo "Tor not running"
    fi
}

# Check Tails
is_tails() {
    if [[ $USER = amnesia ]]; then
        export SWAP_DATADIR=$HOME/Persistent/coinswaps
        export TAILS=1
    fi
}

# Detect OS
detect_os_arch() {
    if [[ $(uname -s) = "Darwin" ]]; then
        # MacOS
        MACOS=1
        if type -p brew > /dev/null; then
            green "Homebrew is installed"
            INSTALL="brew install --quiet"
        else
            green "Installing Homebrew"
            INSTALL="curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash && brew install"
        fi
        DEPENDENCY="python gnupg pkg-config coreutils"
        green "\n\nDetected MacOS"
    elif type -p dnf > /dev/null; then
        # Fedora
        FEDORA=1
        INSTALL="sudo dnf install -y"
        UPDATE="sudo dnf update -y"
        DEPENDENCY="python3-virtualenv python3-pip python3-devel gnupg2 pkgconf"
        green "\n\nDetected Fedora"
    elif type -p pacman > /dev/null; then
        # Arch Linux
        ARCH=1
        INSTALL="sudo pacman -S --noconfirm --needed"
        UPDATE="sudo pacman -Syu --noconfirm"
        DEPENDENCY="python-pipenv gnupg pkgconf base-devel"
        green "\n\nDetected Arch Linux"
    elif type -p apt > /dev/null; then
        # Debian / Ubuntu / Mint / Tails
        if [[ $USER = amnesia ]]; then
            TAILS=1
            green "\n\nDetected Tails"
        else
            DEBIAN=1
            green "\n\nDetected Debian"
        fi
        INSTALL="sudo apt install"
        UPDATE="sudo apt update"
        DEPENDENCY="pipx python3-venv libpython3-dev gnupg pkg-config gcc libc-dev --no-install-recommends"
        if [[ ! $(type -p uv) ]]; then
            PIPX_UV="pipx install uv"
        fi
    else
        red "\nFailed to detect OS. Unsupported or unknown distribution.\nInstall Failed."
        exit
    fi
}
