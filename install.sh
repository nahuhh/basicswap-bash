#/bin/bash

# Colors
cyan="echo -e -n \e[36;1m"
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

# Title Bar
$green "\n"
title="BasicSwapDEX installer"
COLUMNS=$(tput cols)
title_size=${#title}
span=$(((COLUMNS + title_size) / 2))
printf "%${COLUMNS}s" " " | tr " " "*"
printf "%${span}s\n" "$title"
printf "%${COLUMNS}s" " " | tr " " "*"
$nocolor

## Configure Monero node
echo -e "\n\n[1]Connect to a Monero node\n[2]Allow BasicSwapDEX to run a Monero node (+70GB)\n"
until [[ "$l" =~ ^[12]$ ]]; do
read -p 'Select an option: ' l
	case $l in
	 	1) read -p 'Enter Address of Monero node [example: 192.168.1.123] ' monerod_addr
		   read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
		   $green "Look good? $monerod_addr:$monerod_port"; $nocolor;;
	 	2) $green "\nBasicSwapDEX will run the Monero node for you."; $nocolor;;
		*) $red "\nYou must answer 1 or 2\n"; $nocolor;;
	esac
done
echo -e "\nShall we begin?"
read -p 'Press any key to continue, or CTRL-C to exit.'

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
./bsx/activate_venv.sh
