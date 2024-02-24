#/bin/bash
# Download updated scripts
wget -O basicswap-bash.tar.gz https://github.com/nahuhh/basicswap-bash/releases/latest/download/basicswap-bash.tar.gz
tar xvf basicswap-bash.tar.gz
cd basicswap-bash
# Move scripts
sudo rm -rf /usr/local/bin/bsx
sudo mv -f basic* bsx* /usr/local/bin/
# Cleanup install
cd ..
rm -rf basicswap-bash
