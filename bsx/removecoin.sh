#!/bin/bash

## Prompt for user input
if [[ -z "$disablecoin" ]]; then
	printf "\n\nThe following coins can be disabled (case sensitive)\nbitcoin\nbitcoincash\ndash\ndecred\ndogecoin\nfiro\nlitecoin\nmonero\npivx\nwownero\n\n"
	read -p 'Full name of coin to disable [example: wownero] ' disablecoin
fi

## Confirm
printf "\nDisable $disablecoin on your BasicSwap install, correct? Press any key to continue. CTRL-C to exit\n"
read

## Disable the coin
basicswap-prepare --datadir=$SWAP_DATADIR --disablecoin=$disablecoin
