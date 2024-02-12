#!/bin/bash

## Prompt for user input
echo "You can only update coins which you have already added to your install"
echo -e "\n\nList of coins supported by BasicSwapDEX (case sensitive):\nbitcoin\ndash\nfiro\nlitecoin\nmonero\nparticl\npivx\n"
read -p 'Full name of coin to update [example: litecoin] ' updatecoin

## Confirm
read -p $'\nUpdate $updatecoin, correct? Press any key to continue. CTRL-C to exit'

## Update the coin
basicswap-prepare --datadir=$SWAP_DATADIR -preparebinonly --withcoins=$updatecoin
echo "Updated $updatecoin"
