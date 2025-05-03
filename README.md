# basicswap-bash

A suite of bash scripts to install and manage
BasicSwapDEX on Windows(WSL)/Debian/Ubuntu/Arch/Fedora

### Dependencies

You will need::

- curl
- git

```bash
sudo apt install curl git
```

Other dependencies vary by distribution and are handled by the installer.

### New Installation

```bash
git clone https://github.com/nahuhh/basicswap-bash
cd basicswap-bash && ./install.sh
cd .. && rm -rf basicswap-bash
```

### Update scripts from older versions

```bash
cd ~/coinswaps/basicswap
git clone https://github.com/nahuhh/basicswap-bash
cd basicswap-bash
mkdir -p $HOME/.local/bin
rm -r $HOME/.local/bin/bsx
cp -r basic* bsx* $HOME/.local/bin/
cd .. && rm -rf basicswap-bash
bsx-update
```

### Running BasicSwapDEX

```
basicswap-bash
```

#### Update BSX core and Coin cores

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

#### Add/disable coins

```
bsx-addcoin
```

```
bsx-removecoin
```

### BONUS placeorders

This is a POC for placing new orders. YMMV

```
bsx-placeorder
```

A small donation goes a long way. Thanks

- ofrnxmr

```
8Bb9z1bbiKmD9XekA7uESXRzunasN1ndej6FUm1bRFEtSPFqVWvHPtD2LDwhARikcxNkCsmaBcGGF2VSeFWhMe57FGXNaZP
```

[WASS](getwishlisted.xyz/ofrnxmr)
