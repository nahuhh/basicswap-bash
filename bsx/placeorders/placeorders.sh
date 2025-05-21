#!/bin/bash
############################
###########################
#set -x
PORT=12700 # BasicSwapDex http port

# config file location
taker=placebid.json
maker=placeoffer.json
state=placeorders_state.json

# Defaults
ALLOW_SPLIT_ORDERS=true # Sane default TODO
MAXBIDS=10              # TODO
PERCENT=2.5             # Max slippage for "Market" order types

# FUNC - dont touch
BUYORSELL=""
AMOUNT=""
TAKER_RATE=""
MAKER_RATE=""
OB_MIN=""
MIN_MAKER=""
MIN_TAKER=""
###########################
############################

# Colors
cy="printf \e[36;1m"
cy2="\e[36;1m"
red="printf \e[31;1m"
red2="\e[31;1m"
grn="printf \e[32;1m"
grn2="\e[32;1m"
nc="printf \e[0m"
nc2="\e[0m"

# Choose Coins
coin_prompt_buy() {
    THEIR_COIN=$COIN
    theircoin=$coinsymbol
    theircapital=$coinname
}
coin_prompt_sell() {
    YOUR_COIN=$COIN
    yourcoin=$coinsymbol
    yourcapital=$coinname
}
coin() {
    coin=""
    printf "\n[1] Bitcoin\n[2] Monero\n[3] Litecoin\n[4] Firo\n[5] Dash\n[6] Decred\n[7] PIVX\n[8] Particl\n[9] Wownero\n\n"
    until [[ $coin =~ ^[1-9]$ ]]; do
        read -p 'Select an option: ' coin
        case $coin in
            1)
                COIN="bitcoin"
                coinname="Bitcoin"
                coinsymbol="BTC"
                ;;
            2)
                COIN="monero"
                coinname="Monero"
                coinsymbol="XMR"
                ;;
            3)
                COIN="litecoin"
                coinname="Litecoin"
                coinsymbol="LTC"
                ;;
            4)
                COIN="zcoin"
                coinname="Firo"
                coinsymbol="FIRO"
                ;;
            5)
                COIN="dash"
                coinname="Dash"
                coinsymbol="DASH"
                ;;
            6)
                COIN="dcr"
                coinname="Decred"
                coinsymbol="DCR"
                ;;
            7)
                COIN="pivx"
                coinname="PIVX"
                coinsymbol="PIVX"
                ;;
            8)
                COIN="particl"
                coinname="Particl"
                coinsymbol="PART"
                ;;
            9)
                COIN="wownero"
                coinname="Wownero"
                coinsymbol="WOW"
                ;;
            *)
                red "\nYou must answer 1-9\n"
                $nc
                ;;
        esac
    done
}

book_min() {
    if [[ $coin = 1 ]]; then # BITCOIN
        OB_MIN=0.0050
        MIN_SWAP=0.0010
    elif [[ $coin = 2 ]]; then # MONERO
        OB_MIN=0.2000
        MIN_SWAP=0.0300
    elif [[ $coin = 3 ]]; then # LITECOIN
        OB_MIN=0.4000
        MIN_SWAP=0.0600
    elif [[ $coin = 4 ]]; then # FIRO
        OB_MIN=20.0000
        MIN_SWAP=8.0000
    elif [[ $coin = 5 ]]; then # DASH
        OB_MIN=1.0000
        MIN_SWAP=0.2000
    elif [[ $coin = 6 ]]; then # DECRED
        OB_MIN=1.0000
        MIN_SWAP=0.2000
    elif [[ $coin = 7 ]]; then # PIVX
        OB_MIN=50.0000
        MIN_SWAP=10.0000
    elif [[ $coin = 8 ]]; then # PARTICL
        OB_MIN=50.0000
        MIN_SWAP=10.0000
    elif [[ $coin = 9 ]]; then # WOWNERO
        OB_MIN=50.0000
        MIN_SWAP=10.0000
    fi
}

set_fiat() {
    printf "[1] USD [default]\n[2] EUR\n[3] CAD\n[4] AUD\n[5] CUSTOM\n\n"
    read -p 'Select an option: ' fiat_select
    case $fiat_select in
        1)
            FIAT=USD
            fiat=usd
            echo "USD"
            ;;
        2)
            FIAT=EUR
            fiat=eur
            echo "EUR"
            ;;
        3)
            FIAT=CAD
            fiat=cad
            echo "CAD"
            ;;
        4)
            FIAT=AUD
            fiat=aud
            echo "AUD"
            ;;
        5)
            read -p 'Please enter the lowecase 3 character currency code [example: jpy] ' FIAT
            fiat=$FIAT
            ;;
        *)
            FIAT=USD
            fiat=usd
            echo "USD"

            ;;
    esac
}

coin_price() {
    printf "\n\nCurrent Market Rates are..\n"
    curl -s "https://api.coingecko.com/api/v3/simple/price?ids=$THEIR_COIN,$YOUR_COIN&vs_currencies=$fiat" > rates.txt
    YOUR_FIAT=$(cat rates.txt | jq -r ".$YOUR_COIN.$fiat")
    THEIR_FIAT=$(cat rates.txt | jq -r ".$THEIR_COIN.$fiat")
    TAKER_RATE=$(echo $THEIR_FIAT $YOUR_FIAT | awk '{ printf "%.8f\n", $1 / $2 }')
    MAKER_RATE=$(echo $TAKER_RATE | awk '{ printf "%.8f\n", 1 / $1 }')
    $cy"$THEIR_FIAT $FIAT$nc2/$grn2$theircoin$nc2 which is red 2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin$nc2\n"
    $cy"$YOUR_FIAT $FIAT$nc2/red 2$yourcoin$nc2 which is $grn2$MAKER_RATE $theircoin$nc2/red 2$yourcoin$nc2\n"
    rm rates.txt
}

buy_sell() {
    printf "\n\n[1] BUY a specific amount of $grn2$theircapital$nc2\n[2] SELL a specific amount of your red 2$yourcapital$nc2\n\n"
    until [[ $BUYORSELL =~ ^[12]$ ]]; do
        read -p 'Select an option: ' BUYORSELL
        case $BUYORSELL in
            1)
                read -p $'\nHow much '"$theircapital"' do you want to BUY? [example: 1] ' AMOUNT
                $cy"\nRate you will pay:\n"
                $nc
                printf "\n[1] CUSTOM: Specific Crypto Rate red 2$yourcoin$nc2/$grn2$theircoin$nc2\n[2] CUSTOM: red 2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin $cy2+/- CUSTOM Percent$nc2\n[3] PRESET: red 2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin$nc2\n[4] PRESET: red 2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin $cy2+ $PERCENT%%$nc2\n[ENTER] FIAT: Enter a $cy2$FIAT$nc2 rate to pay\n\n"
                read -p 'Select an option: ' RATESEL
                case $RATESEL in
                    1)
                        read -p $"At what rate would you like to Pay? [example: $TAKER_RATE] " RATE
                        PRICE=$(echo $YOUR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        PERCENT=0
                        ;;
                    2)
                        read -p 'Pay this much % above or below market [example: [0.5|-0.5] ' PERCENT
                        RATE=$(echo $TAKER_RATE $PERCENT | awk '{ printf "%.8f\n", ( $1 * ( $2 / 100 + 1 ))}')
                        PRICE=$(echo $YOUR_FIAT * $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        ;;
                    3)
                        RATE=$TAKER_RATE
                        PRICE=$THEIR_FIAT
                        PERCENT=0
                        ;;
                    4)
                        RATE=$(echo $TAKER_RATE $PERCENT | awk '{ printf "%.8f\n", ( $1 * ( $2 / 100 + 1 ))}')
                        PRICE=$(echo $YOUR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        ;;
                    *)
                        read -p $"Enter specific price in $FIAT to PAY? [example: "$THEIR_FIAT"] " PRICE
                        RATE=$(echo $PRICE $YOUR_FIAT | awk '{ printf "%.8f\n", $1 / $2 }')
                        PERCENT=0
                        ;;
                esac
                MAKER_RATE=$(echo $RATE | awk '{ printf "%.8f\n", 1 / $1 }')
                printf "\nPaying: red 2 $PRICE$FIAT$nc2 which is red 2($RATE $yourcoin$nc2/$grn2$theircoin$nc2)\n"
                printf "Rate to be paid: $grn2$MAKER_RATE $theircoin$nc2/red 2$yourcoin$nc2\n\n"
                ;;
            2)
                read -p $'\nHow much YOUR '"$yourcapital"' do you want to SELL [example: 1] ' AMOUNT
                $cy"\nRate to charge:\n"
                $nc
                printf "\n[1] CUSTOM: Specific Crypto Rate $grn2$theircoin$nc2/red 2$yourcoin$nc2\n[2] CUSTOM: $grn2$MAKER_RATE $theircoin$nc2/red 2$yourcoin $cy2+/- CUSTOM Percent$nc2\n[3] PRESET: $grn2$MAKER_RATE $theircoin$nc2/red 2$yourcoin$nc2\n[4] PRESET: $grn2$MAKER_RATE $theircoin$nc2/red 2$yourcoin $cy2+ $PERCENT%%$nc2\n[ENTER] FIAT: Enter a $cy2$FIAT$nc2 rate to charge\n\n"
                read -p 'Select an option: ' RATESEL
                case $RATESEL in
                    1)
                        read -p $"Enter specific rate to Charge? [example: $MAKER_RATE] " RATE
                        PRICE=$(echo $THEIR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        PERCENT=0
                        ;;
                    2)
                        read -p 'Charge this much percent above market [example: [0.5 or -0.5] ] ' PERCENT
                        RATE=$(echo $MAKER_RATE $PERCENT | awk '{ printf "%.8f\n", ( $1 * ( $2 / 100 + 1 ))}')
                        PRICE=$(echo $THEIR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        ;;
                    3)
                        RATE=$MAKER_RATE
                        PRICE=$(echo $THEIR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        PERCENT=0
                        ;;
                    4)
                        RATE=$(echo $MAKER_RATE $PERCENT | awk '{ printf "%.8f\n", ( $1 * ( $2 / 100 + 1 ))}')
                        PRICE=$(echo $THEIR_FIAT $RATE | awk '{ printf "%.2f\n", $1 * $2 }')
                        ;;
                    *)
                        read -p $"Enter specific price in $FIAT to Charge? [example: "$YOUR_FIAT"] " PRICE
                        RATE=$(echo $PRICE $THEIR_FIAT | awk '{ printf "%.8f\n", $1 / $2 }')
                        PERCENT=0
                        ;;
                esac
                TAKER_RATE=$(echo $RATE | awk '{ printf "%.8f\n", 1 / $1 }')
                printf "Selling at $PRICE$FIAT which is a rate of $grn2$RATE $theircoin$nc2/red 2$yourcoin$nc2\n"
                ;;
            *)
                red "\nYou must answer 1 or 2\n"
                $nc
                ;;
        esac
    done
}

# TODO // ENABLE SPLIT ORDERS
split_orders() {
    if [ $ALLOW_SPLIT_ORDERS = true ]; then
        MIN_SWAP=$(echo $AMOUNT $MAXBIDS | awk '{ printf "%.0f\n", $1 / $2 }')
        printf "$cy2#TODO$nc2 Splitting into multiple bids if necessary. red 2$MAXBIDS$nc2 tx at most\n"
    else
        MIN_SWAP=$AMOUNT
        red "One order only. Not Recommended"
        $nc
        echo "$MIN_SWAP"
    fi
}

apply_config() {
    # Convert amount
    MIN_TAKER=$(echo $MIN_SWAP $MAKER_RATE | awk '{ printf "%.8f\n", $1 * $2 }')
    sed -i -z "s/MIN_SWAP/$MIN_TAKER/" $taker
    sed -i -z "s/MIN_SWAP/$MIN_SWAP/" $maker
    sed -i -z "s/COIN_TO_SELL/$yourcapital/" $taker $maker
    sed -i -z "s/COIN_TO_BUY/$theircapital/" $taker $maker
    sed -i -z "s/PERCENT/$PERCENT/" $maker
    sed -i -z "s/MAXBIDS/$MAXBIDS/" $taker
    printf "\nMinumum amt per swap	= $grn2$MIN_TAKER $theircoin$nc2\n"
    printf "			= red 2$MIN_SWAP $yourcoin$nc2\n\n"
    if [[ $BUYORSELL = 1 ]]; then
        MAKERAMOUNT=$(echo $AMOUNT $MAKER_RATE | awk '{ printf "%.8f\n", $1 / $2 }')
        OB_AMOUNT=$MAKERAMOUNT
        INCREMENT=$(echo $OB_AMOUNT | awk '{ printf "%.4f", $1 / 100 }') # TODO make offers repeat
        printf "Outgoing: red 2$MAKERAMOUNT $yourcoin$nc2\n"
        printf "Incoming: $grn2~$AMOUNT $theircoin$nc2\n"
        sed -i -z "s/AMOUNT/$MAKERAMOUNT/g" $maker
        sed -i -z "s/RATE/$MAKER_RATE/" $maker
        sed -i -z "s/RATE/$RATE/" $taker
        sed -i -z "s/AMOUNT/$AMOUNT/g" $taker
        sed -i -z "s/INCREMENT/$INCREMENT/" $maker
    else
        TAKERAMOUNT=$(echo $AMOUNT $MAKER_RATE | awk '{ printf "%.8f\n", $1 * $2 }')
        OB_AMOUNT=$AMOUNT
        INCREMENT=$(echo $OB_AMOUNT | awk '{ printf "%.4f", $1 / 100 }') # TODO make offers repeat
        printf "Outgoing: red 2$AMOUNT $yourcoin$nc2\n"
        printf "Incoming: $grn2~$TAKERAMOUNT $theircoin$nc2\n"
        sed -i -z "s/AMOUNT/$TAKERAMOUNT/g" $taker
        sed -i -z "s/RATE/$TAKER_RATE/" $taker
        sed -i -z "s/RATE/$RATE/" $maker
        sed -i -z "s/AMOUNT/$AMOUNT/g" $maker
        sed -i -z "s/INCREMENT/$INCREMENT/" $maker
    fi
}

revert_config() {
    cp placeorders_state.json.template $state
    cp placeoffer.json.template $maker
    cp placebid.json.template $taker
}

check_bids() {
    # oneshot. Check for matching offers before posting one
    revert_config
    apply_config
    FOUNDBID=$(python3 createoffers.py --configfile $taker --statefile $state --port=$PORT --oneshot --debug | grep "New bid")
    POSTOFFER=$(python3 -c "print($OB_AMOUNT < $OB_MIN)")
    if [[ $FOUNDBID ]]; then
        $grn"Placed bid successfully! Check BasicSwapDEX to confirm\n"
        $nc
    elif [[ $POSTOFFER == True ]] && [[ -z $FOUNDBID ]]; then
        printf "Checking for a matching offer\n"
        printf "No matching offers found red 2:@ !!!$nc2\nBid quantity toored 2 low$nc2 to post to order book.\nTrying again in 30 seconds\n"
        sleep 30
        $cy"Rechecking bids\n"
        $nc
        recheck_bids
    else
        # Post as limit order on the book
        $cy"No matching offers found. Posting to the orderbook\n"
        $nc
        ORDERPLACED=$(python3 createoffers.py --configfile $maker --statefile $state --port=$PORT --oneshot | grep "New offer")
        if [[ $ORDERPLACED ]]; then
            $grn"OFFER POSTED! Please check BasicSwapDEX to confirm\nOffer expires in 4hrs\n"
            $nc
        else
            red "Placing Order failed. Try again$nc2\n"
        fi
    fi
}

recheck_bids() {
    check_bids
    echo rechecking
}

# 1. Choose coins
revert_config
set_fiat

$grn"\n\nName of coin to buy"
$nc
coin
coin_prompt_buy

red "\n\nName of coin to sell"
$nc
coin
coin_prompt_sell

printf "\nBuying: $grn2$theircapital$nc2"
printf "\nSelling: red 2$yourcapital$nc2\n"

#2. Set rates
# Pull Market rate
coin_price
buy_sell
split_orders
book_min

#3. Attempt bid / Post offer
check_bids
