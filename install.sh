#!/bin/bash
#set -x
source $PWD/bsx/shared.sh

# Check if bsx is already installed
chain=(particl monero wownero dash decred firo litecoin bitcoin bitcoincash pivx)
for coin in "${chain[@]}"; do
    if [[ -f "${SWAP_DATADIR}/${coin}/${coin}.conf" ]]; then
        printf "Existing configuration file found at ${SWAP_DATADIR}/${coin}/${coin}.conf\n"
        abort=1
    fi
    if [[ -f "${SWAP_DATADIR}/${coin}/${coin}d.conf" ]]; then
        printf "Existing configuration file found at ${SWAP_DATADIR}/${coin}/${coin}d.conf\n"
        abort=1
    fi
done
if [[ -f "${SWAP_DATADIR}/basicswap.json" ]]; then
    printf "Existing configuration file(s) found at ${SWAP_DATADIR}/basicswap.json.\n"
    abort=1
fi
if [[ $abort ]]; then
    $red"Aborting install\n"; $nocolor; exit
fi


# Check if basicswap is running
is_running

# Title Bar
$green "\n"
title="BasicSwapDEX Installer"
COLUMNS=$(tput cols)
title_size=${#title}
span=$(((COLUMNS + title_size) / 2))
printf "%${COLUMNS}s" " " | tr " " "#"
printf "%${span}s\n" "$title"
printf "%${COLUMNS}s" " " | tr " " "#"
$nocolor

# Detect Operating system
INSTALL=""
UPDATE=""
DEPENDENCY=""

is_tails
detect_os_arch

## Update & Install dependencies
printf "\n\nInstalling dependencies\nPress CTRL-C at password prompt(s) to skip. If skipped, you must install the dependencies manually before proceeding\n\n"
$green"$UPDATE\n$INSTALL $DEPENDENCY curl automake libtool jq\n"; $nocolor
$UPDATE
$INSTALL $DEPENDENCY automake libtool jq

# Enable tor
printf "\n[1] Tor ON (requires sudo)\n[2] Tor OFF\n"
until [[ "$tor_on" =~ ^[12]$ ]]; do
read -p 'Select an option: [1|2]: ' tor_on
	case $tor_on in
		1)
		$green"BasicSwapDEX will use Tor\n";$nocolor
		;;
		2)
		$red"BasicSwapDEX will NOT use Tor\n";$nocolor
		;;
		*)
		$red"You must answer 1 or 2\n";$nocolor
		;;
	esac
done

## Particl restore Seed
printf "\n[1] New Install\n[2] Restore from Particl Seed\n"
until [[ "$restore" =~ ^[12]$ ]]; do
read -p 'Select an option: [1|2]: ' restore
	case $restore in
		1)
		$green"Installing BasicSwapDEX\n"; $nocolor
		;;
		2)
		until [[ "$wordcount" = "24" ]]; do
		read -p $'\nEnter your Particl Seed\n[example: word word word word word...] ' particl_mnemonic
		wordcount=$(echo $particl_mnemonic | wc -w)
			if  [[ $wordcount = 24 ]]; then
				printf "Restoring BasicSwapDEX\n"
				$green"$particl_mnemonic\n";$nocolor
			else
				$red"Try again. Seed must be 24 words\n"; $nocolor
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
		$red"Not using a custom XMR Restore height\n";$nocolor
		;;
		*)
		until [[ "$xmrrestoreheight" =~ ^[0-9]{1,7}$ ]]; do
		read -p $'Enter your Monero Restore Height [example: 2548568] ' xmrrestoreheight
			if  [[ $xmrrestoreheight =~ ^[0-9]{7}$ ]]; then
				$green"Your XMR Restore height: $xmrrestoreheight\n"; $nocolor
			else
				$red"Try again. Must be 1-7 digits\n"; $nocolor
			fi
		done
		;;
	esac
fi

## Configure Monero
printf "\n[1] Connect to a Monero node\n[2] Allow BasicSwapDEX to run a Monero node (+70GB)\n"
until [[ "$l" =~ ^[12]$ ]]; do
read -p 'Select an option [1|2]: ' l
	case $l in
		1)
		until [[ $checknode ]]; do
			read -p 'Enter Address of Monero node [example: 192.168.1.123] ' monerod_addr
			read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
			checknode=$(timeout 10s curl -sk http://$monerod_addr:$monerod_port/get_info | jq .height)
			if [[ $checknode ]]; then
				$green"Successfully connected to the XMR node @ $monerod_addr:$monerod_port\n"; $nocolor
			else
				$red"The node at $monerod_addr:$monerod_port is not accessible. Try again\n"; $nocolor
			fi

		done
		if [[ -z $xmrrestoreheight ]]; then
			xmrrestoreheight="${checknode}"
		fi
			$green"Monero wallet Restore Height set to ${xmrrestoreheight}\n"; $nocolor
		;;
		2)
		tries=0
		until [[ $xmrrestoreheight ]]; do
			if [[ $tries -eq 3 ]]; then
				echo "Failed to get Monero blockchain height. Please run the installer again."
				exit 1
			fi
			tries=$((tries+1))
			$green"Attempt ${tries}/3 to set restore height"
			xmrrestoreheight=$(timeout 10s curl -s http://node3.monerodevs.org:18089/get_info | jq .height)
		done
		$green"BasicSwapDEX will run the Monero node for you.\n"; $nocolor
		$green"Monero wallet Restore Height set to ${xmrrestoreheight}\n"; $nocolor
		;;
		*)
		$red"You must answer 1 or 2\n"; $nocolor
		;;
	esac
done

## Begin Install
printf "\nInstalling BasicSwapDEX\n"
read -p 'Press Enter to continue, or CTRL-C to exit.'

# Quest to make trasher happy
addpath='PATH="$HOME/.local/bin:$PATH"'
trasherdk=$(echo $PATH | grep -F '.local/bin')

if [[ ! -d $HOME/.local/bin ]]; then
    mkdir -p $HOME/.local/bin
fi

if [[ -z $trasherdk ]]; then

    # Bash
    if [[ -f $HOME/.bashrc ]]; then
        echo "export $addpath" | tee -a $HOME/.bashrc
    fi
    # Zsh
    if [[ -f $HOME/.zshrc ]]; then
        echo "export $addpath" | tee -a $HOME/.zshrc
    fi
    # xfce4
    if [[ -f $HOME/.xsessionrc ]]; then
        echo "export $addpath" | tee -a $HOME/.xsessionrc
    fi

fi

# Move scripts to .local/bin
if [[ -d $HOME/.local/bin/bsx ]]; then
    rm -r $HOME/.local/bin/bsx* $HOME/.local/bin/basicswap-bash
fi
cp -r basicswap-bash bsx* $HOME/.local/bin/

## Make venv and set variables for install
export monerod_addr="${monerod_addr}"
export monerod_port="${monerod_port}"
export particl_mnemonic="${particl_mnemonic}"
export xmrrestoreheight="${xmrrestoreheight}"
export tor_on="${tor_on}"
export TAILS="${TAILS}"
python3 -m venv "${SWAP_DATADIR}/venv"

## Activate venv
activate_venv
$HOME/.local/bin/bsx/setup.sh
