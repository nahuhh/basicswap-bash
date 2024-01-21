#/bin/bash

## Configure Monero node
read -p 'Enter Address of Monero node [example: http://192.168.1.123] ' monerod_addr
read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
printf $monerod_addr:$monerod_port
echo -e "\nPress anykey to continue, or CTRL-C to exit." && read

## Update & Install dependencies
sudo apt update
echo "Installing" && sleep 2
sudo apt install -y git wget python3-full python3-pip gnupg unzip protobuf-compiler automake libtool pkg-config curl jq

## Make venv
export SWAP_DATADIR=$HOME/coinswaps
export monerod_addr=$monerod_addr
export monerod_port=$monerod_port
mkdir -p "$SWAP_DATADIR/venv"
python3 -m venv "$SWAP_DATADIR/venv"

## Activate venv
./dep/activate_venv.sh
