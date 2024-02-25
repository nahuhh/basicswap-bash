#!/bin/bash
cd $SWAP_DATADIR/basicswap
git pull
$SWAT_DATADIR/venv/bin/pip install .
