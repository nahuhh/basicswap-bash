#!/bin/bash
source $HOME/.local/bin/bsx/shared.sh

## Prompt for user input
if [[ -z $addcoin ]]; then
    echo -e "\n\nThe following coins can be added (case sensitive)\n${coins}\n"
    read -p 'Full name of coin to add [example: litecoin] ' addcoin
fi

# TODO need to test descriptor wallet, and coins that need reseeding. excluding for now
# bitcoincash doesnt like multiwallet
# firo doesnt like custom wallet names
# ltc-mweb's different wallet file has issues
local_only=(namecoin litecoin pivx bitcoincash firo)
# coins with separate wallet daemons
wallet_daemon_coins=(monero wownero decred)
# electrum
electrum_capable=(bitcoin litecoin)

manage_daemon_false() {
    jq ".chainclients.${addcoin}.manage_daemon = false" \
        $SWAP_DATADIR/basicswap.json > basicswap.tmp && mv basicswap.tmp $SWAP_DATADIR/basicswap.json
}

use_electrum() {
    jq '.chainclients.'${addcoin}'.connection_type = "electrum"' \
        $SWAP_DATADIR/basicswap.json > basicswap.tmp && mv basicswap.tmp $SWAP_DATADIR/basicswap.json
}

existing_config=$(jq .chainclients."${addcoin}" $SWAP_DATADIR/basicswap.json)

## Grab tickers
detect_os_arch
if [[ "${MACOS}" ]]; then
    ticker="$(get_coin_ticker "${addcoin}")"
else
    ticker="${coin_map[$addcoin]}"
fi

## Electrum
for coin in "${electrum_capable[@]}"; do
    if [[ "${coin}" = "${addcoin}" ]]; then
        read -p "Use Electrum for ${addcoin}? [Y/n]: " electrum
        if ! [[ "${electrum}" =~ ^[nN]$ ]]; then
            skip=1
            ticker=$(echo "${ticker,,}")
            use_electrum="--${ticker}-mode=electrum"
            if [[ "${existing_config}" = null ]]; then
                read -p 'Use a custom electrum server? [y/N]: ' server
                if [[ "${server}" =~ ^[yY]$ ]]; then
                    until [[ "$confirm_server" =~ ^[yY]$ ]]; do
                        read -p 'Enter server address. Syntax "<address>:<port>[:<bool_ssl>]" [example: litecoin.stackwallet.com:20063]: ' server_address
                        green "Is this correct? ${server_address} [y/N]: "
                        read -p "" confirm_server
                    done
                    electrum_server_address="--${ticker}-electrum-server=${server_address}"
                    green "Using Electrum server @ ${server_address}"
                else
                    echo "Using preset Electrum servers"
                fi
            fi
        fi
    fi
done

## Remote node
for coin in "${local_only[@]}"; do
    if [[ "${coin}" = "${addcoin}" ]]; then
        skip=1
        break
    fi
done

if ! [[ "${skip}" ]]; then
    # Set wallet name
    wallet_env="${ticker}_WALLET_NAME"
    wallet_name="BSX_${ticker}"

    read -p "Connecting to an external ${ticker} node (core node, NOT electrum)? [y/N]: " remote_node
    if [[ "${remote_node}" =~ ^[yY]$ ]]; then
        existing_config=$(jq .chainclients."${addcoin}" $SWAP_DATADIR/basicswap.json)
        # only set ip, port, login, and wallet name if first time adding coin
        if [[ "${existing_config}" = null ]]; then
            if [[ "decred" != "${addcoin}" ]]; then
                export "${wallet_env}"="${wallet_name}"
            fi

            red "\nNote: YMMV! Only proceed if you know what you are doing, and if your node has been configured to accept connections!"
            red "\nNote: This MAY not work for all coins."
            red "\nWarning: Wallet files may be stored in the datadir of the external node."
            read -p $'\nProceed to add '"${ticker}"$' to your BasicSwap install? Press ENTER to continue. CTRL-C to exit\n'
            until [[ $confirm_node =~ ^[yY]$ ]]; do
                read -p "Enter your node's IP address: " node_ip
                read -p "Enter your node's RPC port: " node_port
                green "Is this the correct RPC address and port: ${node_ip}:${node_port}? [y/N]:"
                read -p "" confirm_node
            done
            rpc_host="${ticker}_RPC_HOST"
            rpc_port="${ticker}_RPC_PORT"
            export "${rpc_host}"="${node_ip}"
            export "${rpc_port}"="${node_port}"

            # only xmr-type coins have optional rpcauth
            if [[ "${wallet_daemon_coins[@]}" =~ "${addcoin}" ]]; then
                read -p "Is the ${ticker} daemon password protected? [y/N]" xmr_pass
            fi

            if [[ "${xmr_pass}" =~ ^[yY]$ ]] || [[ ! "${wallet_daemon_coins[@]}" =~ "${addcoin}" ]]; then
                until [[ "${node_pass}" ]] && [[ "${node_pass}" = "${node_pass2}" ]]; do
                    read -p "Enter the RPC username of your ${ticker} daemon: " node_user
                    read -sp "Enter the RPC password of ${ticker} daemon: " node_pass
                    echo
                    read -sp "Re-enter the RPC password of ${ticker} daemon: " node_pass2
                    if [[ "${node_pass}" != "${node_pass2}" ]]; then
                        red "Passwords dont match. Try again"
                    fi
                done
                rpc_user="${ticker}_RPC_USER"
                rpc_pass="${ticker}_RPC_PWD"
                export "${rpc_user}"="${node_user}"
                export "${rpc_pass}"="${node_pass}"
            fi
        fi
    fi
fi

## Add the coin
fastsync=""
if [[ ! -d "${SWAP_DATADIR}/bitcoin/blocks" ]] && [[ ! "${remote_node}" =~ ^[yY]$ ]] && [[ "${addcoin}" = bitcoin ]]; then
    if [[ -z "${use_electrum}" ]]; then
        read -p 'Use --usebtcfastsync for bitcoin? [Y/n] ' btcfastsync
    else
        echo "Use --usebtcfastsync for bitcoin? This will reduce sync time if you"
        read -p 'decide to switch from Electrum to full node in the future. (~20gb) [Y/n] ' btcfastsync
    fi
    if [[ "${btcfastsync}" =~ ^[nN]$ ]]; then
        echo "Not using btcfastsync"
    else
        green "Using btcfastsync"
        fastsync="--usebtcfastsync"
    fi
fi

basicswap-prepare --datadir=$SWAP_DATADIR --addcoin=$addcoin ${use_electrum:-} ${electrum_server_address:-} ${fastsync:-}
# if re-enabling coin that is using a remote daemon, disable "manage_daemon"
[[ "${remote_node}" =~ ^[yY]$ ]] && [[ -z "${node_ip}" ]] && manage_daemon_false
# addcoin doesnt respect electrum flags if re-enabling
[[ "${existing_config}" != null ]] && [[ "${use_electrum}" ]] && use_electrum && manage_daemon_false
