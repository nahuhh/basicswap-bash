#!/bin/bash

# Check for Tor installation
torinstall=$(apt-cache policy tor | grep "Installed:" | grep -E -o "[0-9]\w+")
if [[ "$torinstall" ]]; then
	echo -e "\nTor is already installed :)"
else
	# Install and configure tor
	echo "Installing Tor..."
	sudo apt install tor -y
fi

# Create HashesControlPassword
echo -e "In the next step you'll choose a password. NOTE: It will be saved in PLAIN TEXT."
read -p "Enter a (new) tor control password [example: 123123] " torcontrolpass
# Edit /etc/tor/torrc
torhashedpass=$(tor --hash-password $torcontrolpass)
enabledcontrol=$(echo "ControlPort 9051")
skipcontrol=$(grep -x "$enabledcontrol" /etc/tor/torrc)
if [[ $skipcontrol ]]; then
	# Use Existing enabled ControlPort and append HashedControlPassword
	echo -e "# Added by basicswap-bash\nHashedControlPassword $torhashedpass" | sudo tee -a /etc/tor/torrc
else
	echo -e "# Added by basicswap-bash\n$enabledcontrol\nHashedControlPassword $torhashedpass" | sudo tee -a /etc/tor/torrc
fi

# Restart tor to apply
sudo systemctl restart tor
echo "Waiting for Tor... 5sec" && sleep 5

# lol are we there yet?
TOR_PROXY_HOST=127.0.0.1
basicswap-prepare --datadir=$SWAP_DATADIR --enabletor

# Workaround: Replace torpassword in various config files
oldtorpass=$(cat $SWAP_DATADIR/basicswap.json | jq -r .tor_control_password)
sed -i "s/$oldtorpass/$torcontrolpass/" $SWAP_DATADIR/*/*.conf $SWAP_DATADIR/basicswap.json
# Fix: localhost binding for btc/ltc/part (etc) configs
sed -i -z "s/\nbind=0.0.0.0/\nbind=127.0.0.1/" $SWAP_DATADIR/*/*.conf
