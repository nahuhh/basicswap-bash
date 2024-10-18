#!/bin/bash

# Colors
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

## Clone basicswap git
cd $SWAP_DATADIR
git clone https://github.com/basicswap/basicswap
cd $SWAP_DATADIR/basicswap

## Macos
if [[ $MACOS ]]; then
    $SWAP_DATADIR/venv/bin/pip install certifi
fi

## Install basicswap, coincurve, and pip dependencies
torsocks $SWAP_DATADIR/venv/bin/pip install -r requirements.txt --require-hashes
torsocks $SWAP_DATADIR/venv/bin/pip install .

## Decide a source for Monero's restore height
if [[ "$xmrrestoreheight" ]]; then
	CURRENT_XMR_HEIGHT=$xmrrestoreheight
elif [[ "$monerod_addr" ]]; then
	# Use custom Monero node
	CURRENT_XMR_HEIGHT=$(curl "http://$monerod_addr:$monerod_port/get_info" | jq .height)
else
	# Use public node
	CURRENT_XMR_HEIGHT=$(curl http://node3.monerodevs.org:18089/get_info | jq .height)
fi

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
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$CURRENT_XMR_HEIGHT --wowrestoreheight=600000 --particl_mnemonic="$PARTICL_MNEMONIC"
	enable_tor
elif [[ "$particl_mnemonic" ]]; then
	# Restore seed
	PARTICL_MNEMONIC=$particl_mnemonic
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$CURRENT_XMR_HEIGHT --wowrestoreheight=600000 --particl_mnemonic="$PARTICL_MNEMONIC"
	enable_tor
elif [[ "$monerod_addr" ]]; then
	# Setup new install and use a remote monero node
	XMR_RPC_HOST=$monerod_addr XMR_RPC_PORT=$monerod_port \
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$CURRENT_XMR_HEIGHT --wowrestoreheight=600000
	$red"\n\nMake note of your seed above\n"; $nocolor
	enable_tor
else
	# Setup new install using local nodes
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero,wownero --xmrrestoreheight=$CURRENT_XMR_HEIGHT --wowrestoreheight=600000
	$red"\n\nMake note of your seed above\n"; $nocolor
	enable_tor
fi

$green"Install complete.\n\nUse 'basicswap-bash' to run, 'bsx-update' to update, and 'bsx-addcoin' to add a coin\n\n";$nocolor
$red"You may have to logout / login or open a new terminal window for the commands to be detected\n";$nocolor
