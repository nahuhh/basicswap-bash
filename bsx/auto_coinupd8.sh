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
bitcoincash
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
  if [[ $coin == bitcoincash ]]; then
    coind="bitcoin"
  elif [[ $coin == decred ]]; then
    coind="dcr"
  else
    coind="$coin"
  fi

  if [[ -d $BINDIR/$coin ]]; then
    UPDATE=$($BINDIR/$coin/"$coind"d --version | head -n 1 | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
    if [[ -z $UPDATE ]]; then
      select+="$coin,"
      list="${select%,}"
    fi
  fi
done

if [[ -n $list ]]; then
  withoutCoins=""
  if [[ ! $list =~ "particl" ]]; then
    withoutCoins="--withoutcoins=particl"
  fi
  echo "Updating $list"
  . $SWAP_DATADIR/venv/bin/activate
  basicswap-prepare --datadir=$SWAP_DATADIR --preparebinonly --withcoins=$list "${withoutCoins}"
else
  echo "Coin Cores are up to date"
fi
