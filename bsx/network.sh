#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

echo -e "[1] Enable network\n[2] Disable network\n"
until [[ "$l" =~ ^[12]$ ]]; do
    read -p 'Select an option [1|2]: ' l
    case $l in
        1)
            ## Prompt for user input
            if [[ -z "$network" ]]; then
                echo -e "\n\nThe following networks can be enabled\n${networks}\n"
                read -p 'Name of network to enable [example: simplex] ' network
            fi

            start_tor || exit

            ## Enable the network
            basicswap-prepare --datadir=$SWAP_DATADIR --addnetwork=$network
            ;;
        2)
            ## Prompt for user input
            if [[ -z "$network" ]]; then
                echo -e "\n\nThe following networks can be disabled\n${networks}\n"
                read -p 'Name of network to disable [example: smsg] ' network
            fi

            ## Confirm
            echo -e "\nDisable $network on your BasicSwap install, correct? Press any key to continue. CTRL-C to exit"
            read

            ## Disable the network
            basicswap-prepare --datadir=$SWAP_DATADIR --disablenetwork=$network
            ;;
        *)
            red "You must answer 1 or 2"
            ;;
    esac
done
