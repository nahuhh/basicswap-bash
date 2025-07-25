#!/bin/bash

# Move scripts
rm -r $HOME/.local/bin/bsx $HOME/.local/bin/basicswap-*
cp -r basicswap-bash bsx* $HOME/.local/bin/.

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf $SWAP_DATADIR/basicswap/build

# BasicSwap, coincurve, and dependencies
# Switch to new repo: basicswap/basicswap
cd $SWAP_DATADIR/basicswap
git remote set-url origin https://github.com/basicswap/basicswap

# Conflicting messages_pb2.py from v0.12.7
if [[ -f basicswap/messages_pb2.py ]]; then
    git restore basicswap/messages_pb2.py
fi

#git checkout master
git pull
$SWAP_DATADIR/venv/bin/pip3 install -r requirements.txt --require-hashes
$SWAP_DATADIR/venv/bin/pip3 install .

# Update Coin Cores
$HOME/.local/bin/bsx/auto_coinupd8.sh

# Cleanup
cd $HOME && rm -rf $SWAP_DATADIR/basicswap/basicswap-bash
