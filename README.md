# basicswap-bash
A suite of bash scripts to install and manage
BasicSwapDEX on Windows(WSL)/Debian/Ubuntu/Arch/Fedora

### New Installation
```bash
git clone https://github.com/nahuhh/basicswap-bash
cd basicswap-bash && ./install.sh
cd .. && rm -rf basicswap-bash
```
### Update scripts from older versions
``` bash
cd ~/coinswaps/basicswap
git clone https://github.com/nahuhh/basicswap-bash
cd basicswap-bash
mkdir -p $HOME/.local/bin
rm -r $HOME/.local/bin/bsx
mv -f basic* bsx* $HOME/.local/bin/
cd .. && rm -rf basicswap-bash
bsx-update
```

### Running BasicSwapDEX
```
basicswap-bash
```
#### Update BSX core
```
bsx-update
```

#### Enable/Disable Tor [post install]
```
bsx-enabletor
```
```
bsx-disabletor
```

#### Add/remove coins
```
bsx-addcoin
```
```
bsx-removecoin
```

#### Update blockchains
```
bsx-upgrade-coins
```


A small donation goes a long way. Thanks
- ofrnxmr
```
8Bb9z1bbiKmD9XekA7uESXRzunasN1ndej6FUm1bRFEtSPFqVWvHPtD2LDwhARikcxNkCsmaBcGGF2VSeFWhMe57FGXNaZP
```
[WASS](getwishlisted.xyz/ofrnxmr)
