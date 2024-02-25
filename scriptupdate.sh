#/bin/bash
# Download updated scripts
curl -LO https://github.com/nahuhh/basicswap-bash/releases/download/beta/basicswap-beta.tar.gz
tar xvf basicswap-beta.tar.gz
cd basicswap-beta
# Move scripts
sudo rm -rf /usr/local/bin/bsx
sudo mv -f basic* bsx* /usr/local/bin/
# Cleanup install
cd ..
rm -rf basicswap-beta
