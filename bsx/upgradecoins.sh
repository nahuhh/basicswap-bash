#!/bin/bash

## Prompt for user input
echo "You can only upgrade coins which you have already added to your install"
echo -e "\n\nList of coins supported by BasicSwapDEX (case sensitive):\nbitcoin\ndash\ndecred\nfiro\nlitecoin\nmonero\nparticl\npivx\nwownero\n"
read -p 'Full name of coin to upgrade [example: litecoin] ' upgradecoin

## Confirm
read -p $'\nUpgrade '$upgradecoin', correct? Press any key to continue. CTRL-C to exit'

## Upgrade the coin
basicswap-prepare --datadir=$SWAP_DATADIR -preparebinonly --withcoins=$upgradecoin
echo "Upgraded $upgradecoin"
