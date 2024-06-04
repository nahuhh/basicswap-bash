#!/bin/bash

## Prompt for user input
echo -e "\n\nThe following coins can be disabled (case sensitive)\nbitcoin\ndash\ndecred\nfiro\nlitecoin\nmonero\npivx\nwownero\n"
read -p 'Full name of coin to disable [example: wownero] ' disablecoin
## Confirm
echo -e "\nDisable $disablecoin on your BasicSwap install, correct? Press any key to continue. CTRL-C to exit"
read
## Disable the coin
basicswap-prepare --datadir=$SWAP_DATADIR --disablecoin=$disablecoin
