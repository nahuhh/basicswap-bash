#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

basicswap-prepare --datadir=$SWAP_DATADIR --disabletor
stop_tor
