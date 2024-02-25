#/bin/bash
# Download Scripts
curl -LO https://github.com/nahuhh/basicswap-bash/releases/download/beta/basicswap-beta.tar.gz
tar xvf basicswap-beta.tar.gz
cd basicswap-beta
# Install BasicSwapDEX
./install.sh
# Cleanup
cd ..
rm -rf basicswap-beta
