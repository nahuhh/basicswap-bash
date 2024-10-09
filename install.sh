#/bin/bash
export SWAP_DATADIR=$HOME/coinswaps

# Colors
red="echo -e -n \e[31;1m"
green="echo -e -n \e[32;1m"
nocolor="echo -e -n \e[0m"

# Check if basicswap is running
if [[ -f $SWAP_DATADIR/particl/particl.pid ]]; then
    bsx_pid=$(cat $SWAP_DATADIR/particl/particl.pid)
    if [[ $bsx_pid ]]; then
        bsx_run=$(pidof particld | grep $bsx_pid)
        if [[ $bsx_run ]]; then
            $red"\nError: BasicSwapDEX is already installed.\n"; $nocolor
            exit
        fi
    fi
fi

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

# Detect Operating system
INSTALL=""
UPDATE=""
DEPENDENCY=""
TAILS=""

check_tails() {
	if [ $USER == amnesia ]; then
	    $green"\nDetected Tails\n";$nocolor
	    TAILS=1
	else
	    $green"\nDetected Debian\n";$nocolor
	fi
}

detect_os_arch() {
    if type -P apt > /dev/null; then
	check_tails
        # Debian / Ubuntu / Mint
        INSTALL="sudo apt install"
        UPDATE="sudo apt update"
        DEPENDENCY="python-is-python3 python3-pip python3-venv gnupg pkg-config"
    elif type -P dnf > /dev/null; then
        # Fedora
        INSTALL="sudo dnf install"
        UPDATE="sudo dnf check-update"
        DEPENDENCY="python3-virtualenv python3-pip python3-devel gnupg2 pkgconf"
	$green"\nDetected Fedora\n";$nocolor
    elif type -P pacman > /dev/null; then
        # Arch Linux
        INSTALL="sudo pacman -S"
        UPDATE="sudo pacman -Syu"
        DEPENDENCY="python-pipenv gnupg pkgconf base-devel"
	$green"\nDetected Arch Linux\n";$nocolor
    elif type -P brew > /dev/null; then
        # MacOS
        INSTALL="brew install"
        DEPENDENCY="python gnupg pkg-config"
	$green"\nDetected MacOS\n";$nocolor
    else
        $red"Failed to detect OS. Unsupported or unknown distribution.\nInstall Failed.";$nocolor
	exit
    fi
}


detect_os_arch

## Update & Install dependencies
echo -e "\n\nInstalling dependencies\nPress CTRL-C at password prompt(s) to skip. If skipped, you must install the dependencies manually before proceeding"
$green"$UPDATE\n$INSTALL $DEPENDENCY curl automake libtool jq\n"; $nocolor
$UPDATE
$INSTALL $DEPENDENCY curl automake libtool jq

# Enable tor
echo -e "\n\n[1] Tor ON (requires sudo)\n[2] Tor OFF\n"
until [[ "$tor_on" =~ ^[12]$ ]]; do
read -p 'Select an option: [1|2] ' tor_on
	case $tor_on in
		1)
		$green"\nBasicSwapDEX will use Tor";$nocolor
		;;
		2)
		$red"\nBasicSwapDEX will NOT use Tor";$nocolor
		;;
		*)
		$red"You must answer 1 or 2\n";$nocolor
		;;
	esac
done

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
		until [[ $checknode ]]; do
			read -p 'Enter Address of Monero node [example: 192.168.1.123] ' monerod_addr
			read -p 'Enter RPC Port for the Monero node [example: 18081] ' monerod_port
			checknode=$(curl -sk http://$monerod_addr:$monerod_port/get_info)
			if [[ $checknode ]]; then
				$green"\nSuccessfully connected to the XMR node @ $monerod_addr:$monerod_port"; $nocolor
			else
				$red"\nThe node at $monerod_addr:$monerod_port is not accessible. Try again\n\n"; $nocolor
			fi
		done
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
echo -e "\n\nInstalling BasicSwapDEX"
read -p 'Press Enter to continue, or CTRL-C to exit.'

# Quest to make trasher happy
addpath='PATH="$HOME/.local/bin:$PATH"'
trasherdk=$(echo $PATH | grep .local/bin)
if ! [[ $trasherdk ]]; then
    mkdir -p $HOME/.local/bin

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
mv -f -t $HOME/.local/bin/ basicswap-bash bsx*

## Make venv and set variables for install
export monerod_addr=$monerod_addr
export monerod_port=$monerod_port
export particl_mnemonic=$particl_mnemonic
export xmrrestoreheight=$xmrrestoreheight
export tor_on=$tor_on
export TAILS=$TAILS
python -m venv "$SWAP_DATADIR/venv"
## Activate venv
$HOME/.local/bin/bsx/activate_venv.sh
