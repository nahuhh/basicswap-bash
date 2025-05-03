#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

activate_venv
basicswap-prepare --datadir=$SWAP_DATADIR --upgradecores
