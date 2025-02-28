#!/bin/bash
## Prompt for user input
if [[ -z $addcoin ]]; then
	printf "\n\nThe following coins can be added (case sensitive)\nbitcoin\nbitcoincash\ndash\ndecred\ndogecoin\nfiro\nlitecoin\npivx\nwownero\n\n"
	read -p 'Full name of coin to add [example: litecoin] ' addcoin
fi

## Confirm
read -p $'\nAdd '$addcoin' to your BasicSwap install, correct? Press ENTER to continue. CTRL-C to exit'

## Add the coin
fastsync=""
if [ $addcoin = bitcoin ]; then
	read -p 'Use --usebtcfastsync for bitcoin? [Y/n] ' btcfastsync

	case $btcfastsync in
		n | N) confirmed=no;;
		*) confirmed=yes;;
	esac

	if [ $confirmed = yes ]; then
		echo "Using btcfastsync"
		fastsync="--usebtcfastsync"
	else
		echo "Not using btcfastsync"
	fi
fi
basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=$addcoin ${fastsync:+${fastsync}}
