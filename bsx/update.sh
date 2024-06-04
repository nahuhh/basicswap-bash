#!/bin/bash
cd $SWAP_DATADIR/basicswap

# Delete dangling build folder. Same as --no-cache for docker
rm -rf ~/coinswaps/basicswap/build
# Fix any conflicts from potential force-pushes
git reset HEAD~5 --hard
# Pull repo
git pull
# Install
$SWAP_DATADIR/venv/bin/pip install .
