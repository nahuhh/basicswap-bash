#!/bin/bash

## Prompt for user input
printf "\n\nThe following coins can be added (case sensitive)\nbitcoin\nbitcoincash\ndash\ndecred\nfiro\nlitecoin\npivx\nwownero\n\n"
read -p 'Full name of coin to add [example: litecoin] ' addcoin
## Confirm
read -p $'\nAdd '$addcoin' to your BasicSwap install, correct? Press ENTER to continue. CTRL-C to exit'

## Add the coin
if [ $addcoin = bitcoin ]; then
	read -p 'Use --usebtcfastsync for bitcoin? [Y/n] ' btcfastsync

	case $btcfastsync in
		n | N) confirmed=no;;
		*) confirmed=yes;;
	esac

	if [ $confirmed = yes ]; then
		echo "Using btcfastsync"
		basicswap-prepare --usebtcfastsync --datadir=$SWAP_DATADIR --addcoin=$addcoin
	else
		echo "Not using btcfastsync"
		basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=$addcoin
	fi
else
		basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=$addcoin
fi
