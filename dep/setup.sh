#!/bin/bash

## Download & Install coincurve stuff
cd $SWAP_DATADIR
wget -O coincurve-anonswap.zip https://github.com/tecnovert/coincurve/archive/refs/tags/anonswap_v0.2.zip
unzip -d coincurve-anonswap coincurve-anonswap.zip
mv ./coincurve-anonswap/*/{.,}* ./coincurve-anonswap || true
cd $SWAP_DATADIR/coincurve-anonswap
pip3 install .

## Clone basicswap git
cd $SWAP_DATADIR
git clone https://github.com/tecnovert/basicswap.git
cd $SWAP_DATADIR/basicswap

## Install basicswap
protoc -I=basicswap --python_out=basicswap basicswap/messages.proto
pip3 install .

# Move scripts to /usr/local/bin
cd $SWAP_DATADIR
sudo mv -f -t /usr/local/bin/ basicswap-bash bsx-*
sudo mkdir /usr/local/bin/bsx/
sudo mv -f -t /usr/local/bin/bsx/ dep/*
## Run basicswap-prepare with particl and monero
CURRENT_XMR_HEIGHT=$(curl "http://$monerod_addr:$monerod_port/get_info" | jq .height)
XMR_RPC_HOST=$monerod_addr BASE_XMR_RPC_PORT=$monerod_port basicswap-prepare --datadir=$SWAP_DATADIR --withcoins=monero --xmrrestoreheight=$CURRENT_XMR_HEIGHT
$red; echo -e "\n\nMake note of your seed above\n"; $nocolor
echo 'Install complete.

Use `basicswap-bash` to run, `bsx-update` to update, and `bsx-addcoin` to add a coin'
