#!/bin/bash
cd $SWAP_DATADIR/basicswap
git pull
$SWAP_DATADIR/venv/bin/pip install .
