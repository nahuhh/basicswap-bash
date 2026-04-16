#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

## Clone basicswap git
cd $SWAP_DATADIR
if [[ -d basicswap ]]; then
    cd $SWAP_DATADIR/basicswap
    git pull || {
        red "Failed to pull repo. Installation aborted"
        exit 1
    }
else
    git clone https://github.com/basicswap/basicswap || {
        red "Failed to clone repo. Please run the installer again"
        exit 1
    }
    cd $SWAP_DATADIR/basicswap
fi

## Install basicswap, coincurve, and pip dependencies
# Macos
if [[ "${MACOS}" ]]; then
    $SWAP_DATADIR/venv/bin/pip3 install certifi
fi

if [[ "${TAILS}" ]]; then
    torsocks $SWAP_DATADIR/venv/bin/pip3 install -r requirements.txt --require-hashes \
        && torsocks $SWAP_DATADIR/venv/bin/pip3 install . || {
        red "Installation failed"
        exit 1
    }
else
    $SWAP_DATADIR/venv/bin/pip3 install -r requirements.txt --require-hashes
    $SWAP_DATADIR/venv/bin/pip3 install .
fi

# Use Tor if we want
enable_tor() {
    if [[ "$tor_on" = 1 ]]; then
        $HOME/.local/bin/bsx-enabletor
    fi
}

# Install bsx
[[ $monerod_addr ]] && export XMR_RPC_HOST=$monerod_addr XMR_RPC_PORT=$monerod_port
[[ $monerod_user ]] && export XMR_RPC_USER=$monerod_user XMR_RPC_PWD=$monerod_pass
basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$xmrrestoreheight --wowrestoreheight=600000 ${particl_mnemonic:+"--particl_mnemonic=\"$particl_mnemonic\""} ${regtest:-} || {
    red "Installation failed. Try again"
    exit 1
}
red "\nMonero wallet restore height is ${xmrrestoreheight}"
[[ -z $particl_mnemonic ]] && red "\nIMPORTANT!! Make note of your seed (wallet recovery phrase) above!!\n\n"
read -p "Press ENTER to continue. "
enable_tor

green "Install complete.\n\nUse 'basicswap-bash' to run, 'bsx-update' to update, and 'bsx-addcoin' to add a coin\n"
red "You may have to logout / login or open a new terminal window for the commands to be detected"
