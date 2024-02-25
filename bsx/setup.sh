#!/bin/bash

# Colors
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

## UBUNTU 22.04 FIX upgrade protobuf inside of venv
python -m pip install --upgrade "protobuf<=3.20.1"

## Download & Install coincurve stuff
cd $SWAP_DATADIR
wget -O coincurve-anonswap.zip https://github.com/tecnovert/coincurve/archive/refs/tags/anonswap_v0.2.zip
unzip -d coincurve-anonswap coincurve-anonswap.zip
mv -f ./coincurve-anonswap/*/{.,}* ./coincurve-anonswap || true
cd $SWAP_DATADIR/coincurve-anonswap
$SWAP_DATADIR/venv/bin/pip install .

## Clone basicswap git
cd $SWAP_DATADIR
git clone https://github.com/tecnovert/basicswap.git
cd $SWAP_DATADIR/basicswap
## Install basicswap
protoc -I=basicswap --python_out=basicswap basicswap/messages.proto
$SWAP_DATADIR/venv/bin/pip install .

## Decide a source for Monero's restore height
if [[ "$xmrrestoreheight" ]]; then
	CURRENT_XMR_HEIGHT=$xmrrestoreheight
elif [[ "$monerod_addr" ]]; then
	# Use custom Monero node
	CURRENT_XMR_HEIGHT=$(curl "http://$monerod_addr:$monerod_port/get_info" | jq .height)
else
	# Use public node
	CURRENT_XMR_HEIGHT=$(curl https://localmonero.co/blocks/api/get_stats | jq .height)
fi

# Use Tor if we want
enable_tor() {
	if [[ "$tor_on" = 1 ]]; then
		/usr/local/bin/bsx-enabletor
	fi
}

# Use the custom Monero node
if   [[ "$particl_mnemonic" && "$monerod_addr" ]]; then
	PARTICL_MNEMONIC=$particl_mnemonic
	basicswap-prepare --datadir=$SWAP_DATADIR --particl_mnemonic="$PARTICL_MNEMONIC"
	XMR_RPC_HOST=$monerod_addr BASE_XMR_RPC_PORT=$monerod_port basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=monero --xmrrestoreheight=$CURRENT_XMR_HEIGHT
	enable_tor
elif [[ "$particl_mnemonic" ]]; then
	PARTICL_MNEMONIC=$particl_mnemonic
	basicswap-prepare --datadir=$SWAP_DATADIR --particl_mnemonic="$PARTICL_MNEMONIC"
	enable_tor
elif [[ "$monerod_addr" ]]; then
	XMR_RPC_HOST=$monerod_addr BASE_XMR_RPC_PORT=$monerod_port basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero --xmrrestoreheight=$CURRENT_XMR_HEIGHT
	$red"\n\nMake note of your seed above\n"; $nocolor
	enable_tor
else
	basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero --xmrrestoreheight=$CURRENT_XMR_HEIGHT
	$red"\n\nMake note of your seed above\n"; $nocolor
	enable_tor
fi

$green"Install complete.\n\nUse 'basicswap-bash' to run, 'bsx-update' to update, and 'bsx-addcoin' to add a coin\n"; $nocolor
