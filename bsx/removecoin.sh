#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

## Prompt for user input
if [[ -z "$disablecoin" ]]; then
    echo -e "\n\nThe following coins can be disabled (case sensitive)\n${coins}\n"
    read -p 'Full name of coin to disable [example: wownero] ' disablecoin
fi

## Confirm
echo -e "\nDisable $disablecoin on your BasicSwap install, correct? Press any key to continue. CTRL-C to exit"
read

## Disable the coin
basicswap-prepare --datadir=$SWAP_DATADIR --disablecoin=$disablecoin
