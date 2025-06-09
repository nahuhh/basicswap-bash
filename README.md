# basicswap-bash

A suite of bash scripts to install and manage
BasicSwapDEX on Windows(WSL)/Debian/Ubuntu/Arch/Fedora

### Dependencies

You will need:

- curl
- git

```bash
sudo apt install curl git
```

Other dependencies vary by distribution and are handled by the installer.

### New Installation

```bash
# Clone repo
git clone https://github.com/nahuhh/basicswap-bash \
&& cd basicswap-bash

# Install BasicSwap
./basicswap-install.sh

# Cleanup
cd .. && rm -rf basicswap-bash
```

### Update scripts from much older versions

```bash
# Clone repo
cd ~/coinswaps/basicswap
git clone https://github.com/nahuhh/basicswap-bash
cd basicswap-bash

# Install scripts
mkdir -p $HOME/.local/bin
rm -r $HOME/.local/bin/bsx
cp -r basicswap-bash bsx* $HOME/.local/bin/

# Cleanup
cd .. && rm -rf basicswap-bash

# Run update
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

#### Enable/Disable Particl staking

```bash
bsx-staking
```

#### Enable/Disable client auth password

```bash
bsx-clientauth
```

#### Enable/Disable Tor [post install]

```
bsx-enabletor
```

```
bsx-disabletor
```

#### Enable/Disable coins

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
