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
MAXBIDS=10 # TODO
PERCENT=2.5 # Max slippage for "Market" order types

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
cy="echo -e -n \e[36;1m"
cy2="\e[36;1m"
red="echo -e -n \e[31;1m"
red2="\e[31;1m"
grn="echo -e -n \e[32;1m"
grn2="\e[32;1m"
nc="echo -e -n \e[0m"
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
	echo -e "\n[1] Bitcoin\n[2] Monero\n[3] Litecoin\n[4] Firo\n[5] Dash\n[6] PIVX\n[7] Particl\n[8] Wownero\n"
	until [[ $coin =~ ^[1-8]$ ]]; do
		read -p 'Select an option: ' coin
		case $coin in
			1) COIN="bitcoin"
			   coinname="Bitcoin"
			   coinsymbol="BTC"
			;;
			2) COIN="monero"
			   coinname="Monero"
			   coinsymbol="XMR"
			;;
			3) COIN="litecoin"
			   coinname="Litecoin"
			   coinsymbol="LTC"
			;;
			4) COIN="zcoin"
			   coinname="Firo"
			   coinsymbol="FIRO"
			;;
			5) COIN="dash"
			   coinname="Dash"
			   coinsymbol="DASH"
			;;
			6) COIN="pivx"
			   coinname="PIVX"
			   coinsymbol="PIVX"
			;;
			7) COIN="particl"
			   coinname="Particl"
			   coinsymbol="PART"
			;;
			8) COIN="wownero"
			   coinname="Wownero"
			   coinsymbol="WOW"
			;;
			*) $red "\nYou must answer 1-8\n"; $nc
			;;
		esac
	done
}

book_min() {
	if   [[ $coin = 1 ]]; then # BITCOIN
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
	elif [[ $coin = 6 ]]; then # PIVX
		OB_MIN=50.0000
		MIN_SWAP=10.0000
	elif [[ $coin = 7 ]]; then # PARTICL
		OB_MIN=50.0000
		MIN_SWAP=10.0000
	elif [[ $coin = 8 ]]; then # WOWNERO
		OB_MIN=50.0000
		MIN_SWAP=10.0000
	fi
}

set_fiat() {
	echo -e "[1] USD [default]\n[2] EUR\n[3] CAD\n[4] AUD\n[5] CUSTOM"
	read -p 'Select an option: ' fiat_select
	case $fiat_select in
		1) FIAT=USD
		   fiat=usd
		;;
		2) FIAT=EUR
		   fiat=eur
		;;
		3) FIAT=CAD
		   fiat=cad
		;;
		4) FIAT=AUD
		   fiat=aud
		;;
		5) read -p 'Please enter the 3 character currency code [example: jpy] ' FIAT
		   fiat=$FIAT
		;;
		*) FIAT=USD
		   fiat=usd
		;;
	esac
}

coin_price() {
	echo -e "\nCurrent Market Rates are.."
	YOUR_FIAT=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=$THEIR_COIN,$YOUR_COIN&vs_currencies=$fiat" | jq -r ".$YOUR_COIN.$fiat")
	THEIR_FIAT=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=$THEIR_COIN,$YOUR_COIN&vs_currencies=$fiat" | jq -r ".$THEIR_COIN.$fiat")
	TAKER_RATE=$(echo "scale=8;( $THEIR_FIAT / $YOUR_FIAT )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
	MAKER_RATE=$(echo "scale=8;(1 / $TAKER_RATE /1)" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
	$cy"$THEIR_FIAT $FIAT$nc2/$grn2$theircoin$nc2 which is $red2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin$nc2\n"
	$cy"$YOUR_FIAT $FIAT$nc2/$red2$yourcoin$nc2 which is $grn2$MAKER_RATE $theircoin$nc2/$red2$yourcoin$nc2\n";
}

buy_sell() {
	echo -e "\n[1] BUY a specific amount of $grn2$theircapital$nc2\n[2] SELL a specific amount of your $red2$yourcapital$nc2\n"
	until [[ $BUYORSELL =~ ^[12]$ ]]; do
		read -p 'Select an option: ' BUYORSELL
		case $BUYORSELL in
			1) read -p "How much $theircapital do you want to BUY? [example: 1] " AMOUNT
			   echo -e "\n4. Rate you will pay:"
			   echo -e "[1] LIMIT: Specific Crypto Rate $red2$yourcoin$nc2/$grn2$theircoin$nc2\n[2] LIMIT: $red2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin $cy2+/- CUSTOM Percent$nc2\n[3] LIMIT: $red2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin$nc2\n[4] MARKET +$PERCENT%: $red2$TAKER_RATE $yourcoin$nc2/$grn2$theircoin $cy2+ $PERCENT%$nc2\n[ENTER] LIMIT: Specific Fiat Rate $cy2$FIAT$nc2/$grn2$theircoin$nc2"
			   read -p 'Select an option: ' RATESEL
			   case $RATESEL in
				1) read -p $"At what rate would you like to Pay? [example: $TAKER_RATE] " RATE
				   PRICE=$(echo "scale=2;( $YOUR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PERCENT=0
				;;
				2) read -p 'Pay this much % above or below market [example: [0.5|-0.5] ' PERCENT
				   RATE=$(echo "scale=8;( $TAKER_RATE * ( $PERCENT / 100 + 1)/1)" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PRICE=$(echo "scale=2;( $YOUR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				;;
				3) RATE=$TAKER_RATE
				   PRICE=$THEIR_FIAT
				   PERCENT=0
				;;
				4) RATE=$(echo "scale=9;( $TAKER_RATE * ( $PERCENT / 100 + 1)/1)" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PRICE=$(echo "scale=2;( $YOUR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				;;
				*) read -p $"Enter specific price in $FIAT to PAY? [example: "$THEIR_FIAT"] " PRICE
				   RATE=$(echo "scale=8;( $PRICE / $YOUR_FIAT )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PERCENT=0
				;;
			   esac
			   MAKER_RATE=$(echo "scale=8;( 1 / $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
			   echo -e "\nPaying: $red2 $PRICE$FIAT$nc2 which is $red2($RATE $yourcoin$nc2/$grn2$theircoin$nc2)"
			   echo -e "Rate to be paid: $grn2$MAKER_RATE $theircoin$nc2/$red2$yourcoin$nc2\n"
			;;
			2) read -p "How much YOUR $yourcapital do you want to SELL [example: 1] " AMOUNT
			   echo -e "\n4. Rate to charge:\n"
			   echo -e "[1] LIMIT: Specific Crypto Rate $grn2$theircoin$nc2/$red2$yourcoin$nc2\n[2] LIMIT: $grn2$MAKER_RATE  $theircoin$nc2/$red2$yourcoin $cy2+/- CUSTOM Percent$nc2\n[3] LIMIT: $grn2$MAKER_RATE $theircoin$nc2/$red2$yourcoin$nc2\n[4] MARKET +$PERCENT%: $grn2$MAKER_RATE $theircoin$nc2/$red2$yourcoin $cy2+ $PERCENT%$nc2\n[ENTER] LIMIT: Specific rate $cy2$FIAT$nc2/$red2$yourcoin$nc2"
			   read -p 'Select an option: ' RATESEL
			   case $RATESEL in
				1) read -p $"Enter specific rate to Charge? [example: $MAKER_RATE] " RATE
				   PRICE=$(echo "scale=2;( $THEIR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PERCENT=0
				;;
				2) read -p 'Charge this much % above or below market [example: [0.5|-0.5] ' PERCENT
				   RATE=$(echo "scale=8;( $MAKER_RATE * ( $PERCENT / 100 + 1)/1)" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PRICE=$(echo "scale=2;( $THEIR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				;;
				3) RATE=$MAKER_RATE
				   PRICE=$(echo "scale=8;( $THEIR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PERCENT=0
				;;
				4) RATE=$(echo "scale=8;( $MAKER_RATE * ( $PERCENT / 100 + 1)/1)" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PRICE=$(echo "scale=8;( $THEIR_FIAT * $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				;;
				*) read -p $"Enter specific price in $FIAT to Charge? [example: "$YOUR_FIAT"] " PRICE
				   RATE=$(echo "scale=8;( $PRICE / $THEIR_FIAT )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
				   PERCENT=0
				;;
				esac
			   TAKER_RATE=$(echo "scale=8;(1 / $RATE )" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
			   echo -e "Selling at $PRICE$FIAT which is a rate of $grn2$RATE $theircoin$nc2/$red2$yourcoin$nc2"
			;;
			*) $red "\nYou must answer 1 or 2\n"; $nc
			;;
		esac
	done
}

# TODO // ENABLE SPLIT ORDERS
split_orders() {
	if [ $ALLOW_SPLIT_ORDERS = true ]; then
		MIN_SWAP=$(echo "scale=0;( $AMOUNT / $MAXBIDS )/1" | bc)
		echo -e "$cy2#TODO$nc2 Splitting into multiple bids if necessary. $red2$MAXBIDS$nc2 tx at most"
	else
		MIN_SWAP=$AMOUNT
		$red"One order only. Not Recommended";$nc
		echo "$MIN_SWAP"
	fi
}

apply_config() {
	# Convert amount
	MIN_TAKER=$(echo "scale=8;( $MIN_SWAP * $MAKER_RATE )/1" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
	sed -i -z "s/MIN_SWAP/$MIN_TAKER/" $taker
	sed -i -z "s/MIN_SWAP/$MIN_SWAP/" $maker
	sed -i -z "s/COIN_TO_SELL/$yourcapital/" $taker $maker
	sed -i -z "s/COIN_TO_BUY/$theircapital/" $taker $maker
	sed -i -z "s/PERCENT/$PERCENT/" $maker
	sed -i -z "s/MAXBIDS/$MAXBIDS/" $taker
	echo -e "\nMinumum amt per swap	= $grn2$MIN_TAKER $theircoin$nc2"
	echo -e "			= $red2$MIN_SWAP $yourcoin$nc2\n"
	if [[ $BUYORSELL = 1 ]]; then
		MAKERAMOUNT=$(echo "scale=8;( $AMOUNT / $MAKER_RATE )/1" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
		echo -e "Outgoing: $red2$MAKERAMOUNT $yourcoin$nc2"
		echo -e "Incoming: $grn2~$AMOUNT $theircoin$nc2"
		sed -i -z "s/AMOUNT/$MAKERAMOUNT/g" $maker
		sed -i -z "s/RATE/$MAKER_RATE/" $maker
		sed -i -z "s/RATE/$RATE/" $taker
		sed -i -z "s/AMOUNT/$AMOUNT/g" $taker
	else
		TAKERAMOUNT=$(echo "scale=8;( $AMOUNT * $MAKER_RATE )/1" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')
		echo -e "Outgoing: $red2$AMOUNT $yourcoin$nc2"
		echo -e "Incoming: $grn2~$TAKERAMOUNT $theircoin$nc2"
		sed -i -z "s/AMOUNT/$TAKERAMOUNT/g" $taker
		sed -i -z "s/RATE/$TAKER_RATE/" $taker
		sed -i -z "s/RATE/$RATE/" $maker
		sed -i -z "s/AMOUNT/$AMOUNT/g" $maker
	fi
}

revert_config() {
	cp placeorders_state.json.template $state
	cp placeoffer.json.template $maker
	cp placebid.json.template $taker
}

check_bids() {
	# oneshot. Check for matching offers before posting one
	apply_config
	FOUNDBID=$(python createoffers.py --configfile $taker --statefile $state --port=$PORT --oneshot --debug | grep "New bid")
 	if [[ $FOUNDBID ]]; then
		$grn"Placed bid successfully! Check BasicSwapDEX to confirm\n";$nc
	elif [[ $AMOUNT < $OB_MIN && -z $FOUNDBID ]]; then
		echo -e "Checking for a matching offer"
		echo -e "No matching offers found $red2:@ !!!$nc2\nBid quantity too$red2 low$nc2 to post to order book.\nTrying again in 30 seconds"
		sleep 2
		revert_config
		sleep 30
		apply_config
		$cy"Rechecking bids\n";$nc
		recheck_bids
	else
		# Post as limit order on the book
		$cy"No matching offers found. Posting to the orderbook\n";$nc
		ORDERPLACED=$(python createoffers.py --configfile $maker --statefile $state --port=$PORT --oneshot | grep "New offer")
		if [[ $ORDERPLACED ]]; then
			revert_config
			$grn"OFFER POSTED! Please check BasicSwapDEX to confirm\n";$nc
		else
			revert_config
			$red"Placing Order failed. Try again$nc2\n"
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

	$grn"\n\nName of coin to buy";$nc
	coin
	coin_prompt_buy

	$red"\n\nName of coin to sell";$nc
	coin
	coin_prompt_sell

	echo -e "Buying: $grn2$theircapital$nc2"
	echo -e "Selling: $red2$yourcapital$nc2"

#2. Set rates
# Pull Market rate
	coin_price
	buy_sell
	# split_orders
	book_min

#3. Attempt bid / Post offer
	check_bids
