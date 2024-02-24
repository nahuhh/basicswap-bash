#/bin/bash
# Download Scripts
wget -O basicswap-bash.tar.gz https://github.com/nahuhh/basicswap-bash/releases/latest/download/basicswap-bash.tar.gz
tar xvf basicswap-bash.tar.gz
cd basicswap-bash
# Install BasicSwapDEX
./install.sh
# Cleanup
cd ..
rm -rf basicswap-bash
