#!/bin/bash
. $SWAP_DATADIR/venv/bin/activate && python -V
if [[ $TAILS ]]; then
/usr/local/bin/bsx/tails_setup.sh
else
/usr/local/bin/bsx/setup.sh
fi
