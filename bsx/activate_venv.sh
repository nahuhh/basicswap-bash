#!/bin/bash
. $SWAP_DATADIR/venv/bin/activate
if [[ $TAILS ]]; then
$HOME/.local/bin/bsx/tails_setup.sh
else
$HOME/.local/bin/bsx/setup.sh
fi
