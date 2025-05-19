#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

activate_venv
start_tor
basicswap-prepare --datadir=$SWAP_DATADIR --upgradecores
stop_tor
