<p align="center">
  <a href="https://layerzero.network">
    <img alt="LayerZero" style="width: 400px" src="https://docs.layerzero.network/img/LayerZero_Logo_White.svg"/>
  </a>
</p>

<p align="center">
  <a href="https://layerzero.network" style="color: #a77dff">Homepage</a> | <a href="https://docs.layerzero.network/" style="color: #a77dff">Docs</a> | <a href="https://layerzero.network/developers" style="color: #a77dff">Developers</a>
</p>

<h1 align="center">OApp Example</h1>

<p align="center">
  <a href="https://docs.layerzero.network/contracts/oapp" style="color: #a77dff">Quickstart</a> | <a href="https://docs.layerzero.network/contracts/oapp-configuration" style="color: #a77dff">Configuration</a> | <a href="https://docs.layerzero.network/contracts/options" style="color: #a77dff">Message Execution Options</a> | <a href="https://docs.layerzero.network/contracts/endpoint-addresses" style="color: #a77dff">Endpoint Addresses</a>
</p>

<p align="center">Template project for getting started with LayerZero's  <code>OApp</code> contract development.</p>

## 1) Developing Contracts

#### Installing dependencies

We recommend using `pnpm` as a package manager (but you can of course use a package manager of your choice):

```bash
pnpm install
```

#### Compiling your contracts

This project supports both `hardhat` and `forge` compilation. By default, the `compile` command will execute both:

```bash
pnpm compile
```

If you prefer one over the other, you can use the tooling-specific commands:

```bash
pnpm compile:forge
pnpm compile:hardhat
```

Or adjust the `package.json` to for example remove `forge` build:

```diff
- "compile": "$npm_execpath run compile:forge && $npm_execpath run compile:hardhat",
- "compile:forge": "forge build",
- "compile:hardhat": "hardhat compile",
+ "compile": "hardhat compile"
```

#### Running tests

Similarly to the contract compilation, we support both `hardhat` and `forge` tests. By default, the `test` command will execute both:

```bash
pnpm test
```

If you prefer one over the other, you can use the tooling-specific commands:

```bash
pnpm test:forge
pnpm test:hardhat
```

Or adjust the `package.json` to for example remove `hardhat` tests:

```diff
- "test": "$npm_execpath test:forge && $npm_execpath test:hardhat",
- "test:forge": "forge test",
- "test:hardhat": "$npm_execpath hardhat test"
+ "test": "forge test"
```

## 2) Deploying Contracts

Set up deployer wallet/account:

- Rename `.env.example` -> `.env`
- Choose your preferred means of setting up your deployer wallet/account:

```
MNEMONIC="test test test test test test test test test test test junk"
or...
PRIVATE_KEY="0xabc...def"
```

To deploy your contracts to your desired blockchains, run the following command in your project's folder:

```bash
npx hardhat lz:deploy
```

More information about available CLI arguments can be found using the `--help` flag:

```bash
npx hardhat lz:deploy --help
```

By following these steps, you can focus more on creating innovative omnichain solutions and less on the complexities of cross-chain communication.

<br></br>

<p align="center">
  Join our community on <a href="https://discord-layerzero.netlify.app/discord" style="color: #a77dff">Discord</a> | Follow us on <a href="https://twitter.com/LayerZero_Labs" style="color: #a77dff">Twitter</a>
</p>

### Sepolia

- AccessController: [0x917b9D8E62739986EC182E0f988C7F938651aFD7](https://sepolia.etherscan.io/address/0x917b9D8E62739986EC182E0f988C7F938651aFD7)
- AddressProvider : [0x219e6e5eaB5d32Ab7cb003b8b473A5c8512191C0](https://sepolia.etherscan.io/address/0x219e6e5eaB5d32Ab7cb003b8b473A5c8512191C0)
- PAR : [0x68E88c802F146eAD2f99F3A91Fb880D1A2509672](https://sepolia.etherscan.io/address/0x68E88c802F146eAD2f99F3A91Fb880D1A2509672)
- BridgeableToken : [0x23f6319939AAA25583d453e7849834cA42c9D278](https://sepolia.etherscan.io/address/0x23f6319939AAA25583d453e7849834cA42c9D278)

### Arbitrum Sepolia

- AccessController: [0x6CFFE4CAacDdFDc641823c23f49eC71158aCd8c5](https://sepolia.arbiscan.io/address/0x6CFFE4CAacDdFDc641823c23f49eC71158aCd8c5)
- AddressProvider : [0xc0459Eff90be3dCd1aDA71E1E8BDB7619a16c1A4](https://sepolia.arbiscan.io/address/0xc0459Eff90be3dCd1aDA71E1E8BDB7619a16c1A4)
- PAR : [0x78C48A7d7Fc69735fDab448fe6068bbA44a920E6](https://sepolia.arbiscan.io/address/0x78C48A7d7Fc69735fDab448fe6068bbA44a920E6)
- BridgeableToken : [0x5208f5dE46c25273E2Fb8d5a73d605997BC4CA3F](https://sepolia.arbiscan.io/address/0x5208f5dE46c25273E2Fb8d5a73d605997BC4CA3F)

### Amoy

- AccessController: [0x68E88c802F146eAD2f99F3A91Fb880D1A2509672](https://amoy.polygonscan.com/address/0x68E88c802F146eAD2f99F3A91Fb880D1A2509672)
- AddressProvider : [0x5208f5dE46c25273E2Fb8d5a73d605997BC4CA3F](https://amoy.polygonscan.com/address/0x5208f5dE46c25273E2Fb8d5a73d605997BC4CA3F)
- PAR : [0xa04a24Ac56b878877b273A969370Bb4E6e0196e5](https://amoy.polygonscan.com/address/0xa04a24Ac56b878877b273A969370Bb4E6e0196e5)
- BridgeableToken : [0xa8FFF51a77d03F625178cB521586F9d3445b9675](https://amoy.polygonscan.com/address/0xa8FFF51a77d03F625178cB521586F9d3445b9675)
