#!/bin/bash

# Colors
red="printf \e[31;1m"
green="printf \e[32;1m"
nocolor="printf \e[0m"

## Clone basicswap git
cd $SWAP_DATADIR
if [[ -d basicswap ]]; then
    cd $SWAP_DATADIR/basicswap
    git pull || { $red"Failed to pull repo. Installation aborted"; exit; }
else
    git clone https://github.com/basicswap/basicswap || { $red"Failed to clone repo. Please run the installer again"; exit; }
    cd $SWAP_DATADIR/basicswap
fi

## Macos
if [[ $MACOS ]]; then
    $SWAP_DATADIR/venv/bin/pip3 install certifi
fi

## Install basicswap, coincurve, and pip dependencies
torsocks $SWAP_DATADIR/venv/bin/pip3 install -r requirements.txt --require-hashes
torsocks $SWAP_DATADIR/venv/bin/pip3 install .

# Use Tor if we want
enable_tor() {
	if [[ "$tor_on" = 1 ]]; then
		$HOME/.local/bin/bsx-enabletor
	fi
}

# Use the custom Monero node & add wownero because its a small chain
if   [[ "$particl_mnemonic" && "$monerod_addr" ]]; then
	# Restore seed
	PARTICL_MNEMONIC=$particl_mnemonic
	XMR_RPC_HOST=$monerod_addr XMR_RPC_PORT=$monerod_port \
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$xmrrestoreheight --wowrestoreheight=600000 --particl_mnemonic="$PARTICL_MNEMONIC" || { $red"Installation failed. Try again"; exit; }
	$red"\n\nMonero wallet restore height is ${xmrrestoreheight}"; $nocolor
	enable_tor
elif [[ "$particl_mnemonic" ]]; then
	# Restore seed
	PARTICL_MNEMONIC=$particl_mnemonic
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$xmrrestoreheight --wowrestoreheight=600000 --particl_mnemonic="$PARTICL_MNEMONIC" || { $red"Installation failed. Try again"; exit; }
	$red"\n\nMonero wallet restore height is ${xmrrestoreheight}"; $nocolor
	enable_tor
elif [[ "$monerod_addr" ]]; then
	# Setup new install and use a remote monero node
	XMR_RPC_HOST=$monerod_addr XMR_RPC_PORT=$monerod_port \
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$xmrrestoreheight --wowrestoreheight=600000 || { $red"Installation failed. Try again"; exit; }
	$red"\n\nMonero wallet restore height is ${xmrrestoreheight}"; $nocolor
	$red"\n\nMake note of your seed above\n\n"; $nocolor
	enable_tor
else
	# Setup new install using local nodes
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$xmrrestoreheight --wowrestoreheight=600000 || { $red"Installation failed. Try again"; exit; }
	$red"\n\nMonero wallet restore height is ${xmrrestoreheight}"; $nocolor
	$red"\n\nMake note of your seed above\n\n"; $nocolor
	enable_tor
fi

$green"Install complete.\n\nUse 'basicswap-bash' to run, 'bsx-update' to update, and 'bsx-addcoin' to add a coin\n\n";$nocolor
$red"You may have to logout / login or open a new terminal window for the commands to be detected\n";$nocolor
