#!/bin/bash
#set -x
export SWAP_DATADIR=$HOME/coinswaps
if [[ $USER == amnesia ]]; then
    export SWAP_DATADIR=$HOME/Persistent/coinswaps
fi
BINDIR=$SWAP_DATADIR/bin

echo "Checking for Coin updates" && sleep 1

chain=(
bitcoin
dash
decred
firo
litecoin
particl
pivx
monero
wownero
)

list=""
select=""
for coin in "${chain[@]}"; do
  if [[ -d $BINDIR/$coin ]]; then
    if [[ $coin == decred ]]; then
      UPDATE=$($BINDIR/$coin/dcrd --version | head -n 1 | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
    else
      UPDATE=$($BINDIR/$coin/"$coin"d --version | head -n 1 | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
    fi
    if [[ -z $UPDATE ]]; then
      select+="$coin,"
      list=${select%,}
    fi
  fi
done

echo "Updating $list"

if [[ -n $select ]]; then
  . $SWAP_DATADIR/venv/bin/activate
  basicswap-prepare --datadir=$SWAP_DATADIR --preparebinonly --withcoins=$list
else
  echo "Coin Cores are up to date"
fi
