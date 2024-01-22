#!/bin/bash

## Prompt for user input
echo -e "\n\nThe following coins can be added (case sensitive)\nbitcoin\ndash\nfiro\nlitecoin\nparticl\nPIVX\n"
read -p 'Full name of coin to add [example: litecoin] ' addcoin
## Confirm
echo -e "\nAdd $addcoin to your BasicSwap install, correct? Press any key to continue. CTRL-C to exit"
read
## Add the coin
if [ $addcoin = bitcoin ]; then
	read -p 'Use --usebtcfastsync for bitcoin? [Y/n] ' btcfastsync

	case $btcfastsync in
		n | N) confirmed=no;;
		*) confirmed=yes;;
	esac

	if [ $confirmed = yes ]; then
		echo using btcfastsync
		basicswap-prepare --usebtcfastsync --datadir=/$SWAP_DATADIR --addcoin=$addcoin
	else
		echo "not using btcfastsync"
		basicswap-prepare --datadir=/$SWAP_DATADIR --addcoin=$addcoin
	fi
else
		echo "not using bitcoin, using $addcoin"
		basicswap-prepare --datadir=/$SWAP_DATADIR --addcoin=$addcoin
fi
