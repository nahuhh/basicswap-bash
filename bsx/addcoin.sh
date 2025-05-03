#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

## Prompt for user input
if [[ -z $addcoin ]]; then
	printf "\n\nThe following coins can be added (case sensitive)\n${coins}\n\n"
	read -p 'Full name of coin to add [example: litecoin] ' addcoin
fi

## Confirm
read -p $'\nAdd '$addcoin' to your BasicSwap install, correct? Press ENTER to continue. CTRL-C to exit'

## Add the coin
fastsync=""
if [ $addcoin = bitcoin ]; then

	read -p 'Use --usebtcfastsync for bitcoin? [Y/n] ' btcfastsync
	if [[ "${btcfastsync}" =~ ^[nN]$ ]]; then
		echo "Not using btcfastsync"
	else
		echo "Using btcfastsync"
		fastsync="--usebtcfastsync"
	fi
fi
basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=$addcoin ${fastsync:+$fastsync}
