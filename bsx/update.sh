#!/bin/bash
cd $SWAP_DATADIR/basicswap

# Download updated scripts
echo "Updating basicswap-bash scripts" && sleep 1
git clone https://github.com/nahuhh/basicswap-bash -b dev
cd basicswap-bash
# Move scripts
rm -rf $HOME/.local/bin/bsx
mv -f basic* bsx* $HOME/.local/bin/
# Cleanup install
cd $SWAP_DATADIR/basicswap
rm -rf basicswap-bash

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf $SWAP_DATADIR/basicswap/build
# Switch to new repo: basicswap/basicswap
git remote set-url origin https://github.com/basicswap/basicswap
# Fix conflicts from force-pushes and rebase
git checkout master
# Pull repo
git pull
# Install
$SWAP_DATADIR/venv/bin/pip install .
