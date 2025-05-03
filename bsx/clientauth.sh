#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

printf "[1] Enable client auth\n[2] Disable client auth\n\n"
$red"NOTE: this a different password than your Wallet Encryption\n";$nocolor
until [[ "$l" =~ ^[12]$ ]]; do
read -p 'Select an option [1|2]: ' l
    case $l in
        1)
        until [[ $pass1 ]] && [[ $pass1 == $pass2 ]]; do
            read -sp 'New Client password: ' pass1
            read -sp $'\nRe-enter Client password: ' pass2
            if [[ $pass1 == $pass2 ]]; then
                CLIENT_AUTH=$pass1
                basicswap-prepare --datadir=$SWAP_DATADIR --client-auth-password="${CLIENT_AUTH}"
                printf "\nThe auth is: ";$green'"admin:<password>"\n\n';$nocolor
                printf "For the AMM, add: "; $green'"auth": "admin:<password>"';$nocolor" to your createoffers.json\n\n"
            else
                $red"\nThe passwords entered don't match. Try again\n\n";$nocolor
            fi
        done
        ;;
        2)
        $nocolor"\Disabling client auth\n"
        basicswap-prepare --datadir=$SWAP_DATADIR --disable-client-auth
        ;;
        *)
        $red"You must answer 1 or 2\n";$nocolor
        ;;
    esac
done
