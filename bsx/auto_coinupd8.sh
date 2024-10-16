#!/bin/bash
#set -x
SWAP_DATADIR=$HOME/coinswaps

echo "Checking for Coin updates" && sleep 1

if [[ -d $SWAP_DATADIR/bin/bitcoin ]]; then
  BTC=$($SWAP_DATADIR/bin/bitcoin/bitcoind --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $BTC ]]; then
    echo "Updating Bitcoin"
    Bitcoin="bitcoin,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/dash ]]; then
  DASH=$($SWAP_DATADIR/bin/dash/dashd --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $DASH ]]; then
    echo "Updating Dash"
    Dash="dash,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/decred ]]; then
  DCR=$($SWAP_DATADIR/bin/decred/dcrd --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $DCR ]]; then
    echo "Updating Decred"
    Decred="decred,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/firo ]]; then
  FIRO=$($SWAP_DATADIR/bin/firo/firod --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $FIRO ]]; then
    echo "Updating Firo"
    Firo="firo,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/litecoin ]]; then
  LTC=$($SWAP_DATADIR/bin/litecoin/litecoind --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $LTC ]]; then
    echo "Updating Litecoin"
    Litecoin="litecoin,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/particl ]]; then
  PART=$($SWAP_DATADIR/bin/particl/particld --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $PART ]]; then
    echo "Updating Particl"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/pivx ]]; then
  PIVX=$($SWAP_DATADIR/bin/pivx/pivxd --version | grep version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $PIVX ]]; then
    echo "Updating PIVX"
    Pivx="pivx,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/monero ]]; then
  XMR=$($SWAP_DATADIR/bin/monero/monerod --version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $XMR ]]; then
    echo "Updating Monero"
    Monero="monero,"
  fi
fi

if [[ -d $SWAP_DATADIR/bin/wownero ]]; then
  WOW=$($SWAP_DATADIR/bin/wownero/wownerod --version | grep -Fxf $SWAP_DATADIR/basicswap/core_versions)
  if [[ -z $WOW ]]; then
    echo "Updating Wownero"
    Wownero="wownero,"
  fi
fi

sleep 1

if [[ -n $Bitcoin ]] || [[ -n $Dash ]] || [[ -n $Decred ]] || [[ -n $Firo ]] || [[ -n $Litecoin ]] || [[ -n $Particl ]] || [[ -n $Pivx ]] || [[ -n $Monero ]] || [[ -n $Wownero ]]; then
  . $SWAP_DATADIR/venv/bin/activate
  basicswap-prepare --datadir=$SWAP_DATADIR --preparebinonly --withcoins="$Bitcoin$Dash$Decred$Firo$Litecoin$Pivx$Monero$Wownero"particl
else
  echo "Coin Cores are up to date"
fi
