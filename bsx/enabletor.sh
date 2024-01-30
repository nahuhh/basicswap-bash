#!/bin/bash

# TODO: check for tor instead of YOLOing it
# Install and configure tor
sudo apt install tor -y
# Create HashesControlPassword
echo -e "In the next step you'll choose a password. NOTE: It will be saved in PLAIN TEXT."
read -p "Enter a (new) tor control password [example: 123123] " torcontrolpass
torhashedpass=$(tor --hash-password $torcontrolpass)

# Remove conflicting ControlPort if enabled
sudo sed -i -z "s/\nControlPort 9051//" /etc/tor/torrc
# Add New ControlPort and HashedControlPassword
echo -e "\n#Added by BSX\nControlPort 9051\nHashedControlPassword $torhashedpass" | sudo tee -a /etc/tor/torrc

# Restart tor to apply
sudo systemctl restart tor
echo "waiting for tor" && sleep 5

# lol are we there yet?
TOR_PROXY_HOST=127.0.0.1
basicswap-prepare --datadir=$SWAP_DATADIR --enabletor
# Replace torpassword in various config files
oldtorpass=$(cat $SWAP_DATADIR/basicswap.json | jq -r .tor_control_password)
sed -i "s/$oldtorpass/$torcontrolpass/" $SWAP_DATADIR/*/*.conf $SWAP_DATADIR/basicswap.json
# localhost binding for btc/ltc/part (etc) configs
sed -i -z "s/\nbind=0.0.0.0/\nbind=127.0.0.1/" $SWAP_DATADIR/*/*.conf
# TODO edit use tor proxy for with coin upgrades
