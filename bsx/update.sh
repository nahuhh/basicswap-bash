#!/bin/bash
COINCURVE=0.2
cd $SWAP_DATADIR/basicswap

# Download updated scripts
echo "Updating basicswap-bash scripts" && sleep 1
git clone https://github.com/nahuhh/basicswap-bash -b placeorders
cd basicswap-bash

# Move scripts
rm -rf $HOME/.local/bin/bsx
mv -f basic* bsx* $HOME/.local/bin/

# Copy core_versions to basicswap folder
mv core_versions $SWAP_DATADIR/basicswap/core_versions

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf $SWAP_DATADIR/basicswap/build

# Coincurve
cd $SWAP_DATADIR
if [[ -d coincurve-basicswap ]]; then
    cd coincurve-basicswap
    git pull
    git checkout basicswap_v$COINCURVE
else
    git clone https://github.com/basicswap/coincurve -b basicswap_v$COINCURVE coincurve-basicswap && cd $_
fi
$SWAP_DATADIR/venv/bin/pip install .

# BasicSwap
# Switch to new repo: basicswap/basicswap
cd $SWAP_DATADIR/basicswap
git remote set-url origin https://github.com/basicswap/basicswap
# git checkout master
git pull

# Update BasicSwap
$SWAP_DATADIR/venv/bin/pip install .

# Update Coin Cores
$HOME/.local/bin/bsx/auto_coinupd8.sh

# Cleanup
rm -rf basicswap-bash
