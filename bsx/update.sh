#!/bin/bash
cd $SWAP_DATADIR/basicswap

# Download updated scripts
echo "Updating basicswap-bash scripts" && sleep 1
git clone https://github.com/nahuhh/basicswap-bash -b dev
cd basicswap-bash
# Move scripts
sudo rm -rf $HOME/.local/bin/bsx
sudo mv -f basic* bsx* $HOME/.local/bin/
# Cleanup install
cd ..
rm -rf basicswap-bash

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf ~/coinswaps/basicswap/build
# Fix conflicts from force-pushes
git reset HEAD~5 --hard
# Pull repo
git pull
# Install
$SWAP_DATADIR/venv/bin/pip install .
