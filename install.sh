#/bin/bash

# Colors
cyan="echo -e -n \e[36;1m"
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

# Title Bar
$green
echo -e "\n"
title="BasicSwapDEX installer"
COLUMNS=$(tput cols)
title_size=${#title}
span=$(((COLUMNS + title_size) / 2))
printf "%${COLUMNS}s" " " | tr " " "*"
printf "%${span}s\n" "$title"
printf "%${COLUMNS}s" " " | tr " " "*"
$nocolor

## Configure Monero node
read -p $'\n\nEnter Address of Monero node [example: http://192.168.1.123] ' monerod_addr
read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
$green; printf $monerod_addr:$monerod_port; $nocolor
echo -e "\nPress any key to continue, or CTRL-C to exit." && read

## Update & Install dependencies
sudo apt update
sudo apt install -y git wget python3-full python3-pip gnupg unzip protobuf-compiler automake libtool pkg-config curl jq

## Make venv
export SWAP_DATADIR=$HOME/coinswaps
export monerod_addr=$monerod_addr
export monerod_port=$monerod_port
mkdir -p "$SWAP_DATADIR/venv"
python3 -m venv "$SWAP_DATADIR/venv"

## Activate venv
./dep/activate_venv.sh
