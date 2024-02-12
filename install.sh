#/bin/bash

# Colors
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

# Title Bar
$green "\n"
title="BasicSwapDEX Installer"
COLUMNS=$(tput cols)
title_size=${#title}
span=$(((COLUMNS + title_size) / 2))
printf "%${COLUMNS}s" " " | tr " " "*"
printf "%${span}s\n" "$title"
printf "%${COLUMNS}s" " " | tr " " "*"
$nocolor

## Particl restore Seed
echo -e "\n\n[1] New Install (default)\n[2] Restore from Particl Seed\n"
until [[ "$restore" =~ ^[12]$ ]]; do
read -p 'Select an option: [1|2] ' restore
	case $restore in
		1)
		$green"\nInstalling BasicSwapDEX\n"; $nocolor
		;;
		2)
		until [[ "$wordcount" = "24" ]]; do
		read -p $'\nEnter your Particl Seed\n[example: word word word word word...] ' particl_mnemonic
		wordcount=$(echo $particl_mnemonic | wc -w)
			if  [[ $wordcount = 24 ]]; then
				echo -e "Restoring BasicSwapDEX"
				$green"$particl_mnemonic\n";$nocolor
			else
				$red"Try again. Seed must be 24 words"; $nocolor
			fi
		done
		;;
		*)
		$red"You must answer 1 or 2\n";$nocolor
		;;
	esac
done

# Monero restore height
if [[ $particl_mnemonic ]]; then
	read -p $'\nEnter a restore height for your BasicSwap XMR wallet? [Y/n] ' height
	case $height in
		n|N)
		$red"\nNot using a custom XMR Restore height";$nocolor
		;;
		*)
		until [[ "$xmrrestoreheight" =~ ^[0-9]{1,7}$ ]]; do
		read -p $'Enter your Monero Restore Height [example: 2548568] ' xmrrestoreheight
			if  [[ $xmrrestoreheight =~ ^[0-9]{7}$ ]]; then
				$green"\nYour XMR Restore height: $xmrrestoreheight"; $nocolor
			else
				$red"Try again. Must be 1-7 digits\n"; $nocolor
			fi
		done
		;;
	esac
fi

## Configure Monero
echo -e "\n[1] Connect to a Monero node\n[2] Allow BasicSwapDEX to run a Monero node (+70GB)\n"
until [[ "$l" =~ ^[12]$ ]]; do
read -p 'Select an option [1|2]: ' l
	case $l in
		1)
		read -p 'Enter Address of Monero node [example: 192.168.1.123] ' monerod_addr
		read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
		$green"\nLook good? $monerod_addr:$monerod_port"; $nocolor
		;;
		2)
		$green"\nBasicSwapDEX will run the Monero node for you."; $nocolor
		;;
		*)
		$red"You must answer 1 or 2\n"; $nocolor
		;;
	esac
done

## Begin Install
echo -e "\n\nShall we begin?"
read -p 'Press Enter to continue, or CTRL-C to exit.'
## Update & Install dependencies
sudo apt update # python-is-python3 for ubuntu
sudo apt install -y git wget python-is-python3 python3-venv python3-pip gnupg unzip protobuf-compiler automake libtool pkg-config curl jq
# Move scripts to /usr/local/bin
sudo mv -f -t /usr/local/bin/ basicswap-bash bsx*
## Make venv and set variables for install
export SWAP_DATADIR=$HOME/coinswaps
export monerod_addr=$monerod_addr
export monerod_port=$monerod_port
export particl_mnemonic=$particl_mnemonic
export xmrrestoreheight=$xmrrestoreheight
mkdir -p "$SWAP_DATADIR/venv"
python3 -m venv "$SWAP_DATADIR/venv"
## Activate venv
/usr/local/bin/bsx/activate_venv.sh
