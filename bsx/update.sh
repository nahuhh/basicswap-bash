#!/bin/bash
COINCURVE=0.2

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf $SWAP_DATADIR/basicswap/build

# BasicSwap, coincurve, and dependencies
# Switch to new repo: basicswap/basicswap
cd $SWAP_DATADIR/basicswap
git remote set-url origin https://github.com/basicswap/basicswap
# git checkout master
git pull

# Update BasicSwap
$SWAP_DATADIR/venv/bin/pip install -r requirements.txt --require-hashes
$SWAP_DATADIR/venv/bin/pip install .

# Update Coin Cores
$HOME/.local/bin/bsx/auto_coinupd8.sh

# Cleanup
rm -rf basicswap-bash
