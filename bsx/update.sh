#!/bin/bash
COINCURVE=0.2

echo "Updating BasicSwapDEX" && sleep 1
# Delete dangling build folder. Same as --no-cache for docker
rm -rf $SWAP_DATADIR/basicswap/build

# Coincurve
cd $SWAP_DATADIR
if [[ -d coincurve-basicswap ]]; then
    cd coincurve-basicswap
    git fetch
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
