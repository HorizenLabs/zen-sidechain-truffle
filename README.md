# Truffle with the Zen EVM sidechain

## Setup

### Installation

First of all it’s required to install the framework itself.

```shell
npm install -g truffle
```

If any problem, please refer to
the [Truffle installation guide](https://trufflesuite.com/docs/truffle/getting-started/installation/).

### Initialize a new Truffle project

This will create the basic directory structure of a Truffle project in a new folder.

```bash
mkdir truffle-project
cd truffle-project
truffle init
npm init -y
```

### Edit configuration to support ZEN network

In the truffle-config.js file, add into the "networks" section the following code:

```javascript
{
  ...
  networks: {
    zen: {
      provider: () => new HDWalletProvider({
        mnemonic: "word1 ... word12",
        providerOrUrl: "https://evm-tn-m2.horizenlabs.io/ethv1"
      }),
      network_id: 1661,
      production: false
    }
  }
  ...
}
```

Replacing the "word1 ... word12" with the mnemonic phrase for a valid Wallet. Please, note that network_id is different depending on the environment you are using.

Also uncomment the line:

```javascript
const HDWalletProvider = require('@truffle/hdwallet-provider');
```

and install it via NPM: `npm install @truffle/hdwallet-provider`.

## Usage

### Get basic information

Using `truffle console --network zen` you can enter an interactive JavaScript console which comes preconfigured with Truffle and the configuration already setup. This way you can get information like the current block height, the chainId and much more:
```shell
truffle(zen)> web3.eth.getBlockNumber()
2976
truffle(zen)> web3.eth.getChainId()
1661
```

### Deploy a contract

Deploying a standard ERC20 contract based on the implementation by [OpenZeppelin](https://www.openzeppelin.com/) can be done with the following steps:
- install the openzeppelin contracts via NPM: `npm install @openzeppelin/contracts`
- create a new contract in the `contracts` folder, see [contracts/DemoERC20.sol](contracts/DemoToken.sol)
- add a deployment script in the `migrations` folder, see [migrations/1_deploy_DemoToken.js](migrations/1_deploy_DemoToken.js)
- execute the script: `truffle migrate --network zen`

#### Example output
```shell
> truffle migrate --network zen

Compiling your contracts...
===========================
> Compiling ./contracts/DemoToken.sol
> Compiling @openzeppelin/contracts/token/ERC20/ERC20.sol
> Compiling @openzeppelin/contracts/token/ERC20/IERC20.sol
> Compiling @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol
> Compiling @openzeppelin/contracts/utils/Context.sol
> Artifacts written to /home/gigo/code/zen-sidechain-truffle/build/contracts
> Compiled successfully using:
   - solc: 0.8.17+commit.8df45f5f.Emscripten.clang


Starting migrations...
======================
> Network name:    'zen'
> Network id:      1661
> Block gas limit: 30000000 (0x1c9c380)


1_deploy_DemoToken.js
=====================

   Deploying 'DemoToken'
   ---------------------
   > transaction hash:    0x41063db41456727a863e33670450cdb8b8bd87e5e25decf76b551e5b6b88110f
   > Blocks: 0            Seconds: 188
   > contract address:    0x3aeFC08E17f681155396D061FBf1Aa622823122b
   > block number:        3624
   > block timestamp:     1666287964
   > account:             0x7507Cebb915af00019be3a5FE8897b2eE115B166
   > balance:             0.397071852433176985
   > gas used:            1171259 (0x11df3b)
   > gas price:           2.500000007 gwei
   > value sent:          0 ETH
   > total cost:          0.002928147508198813 ETH

   > Saving artifacts
   -------------------------------------
   > Total cost:     0.002928147508198813 ETH

Summary
=======
> Total deployments:   1
> Final cost:          0.002928147508198813 ETH
```

### Interacting with the contract

Using the Truffle console interacting with the deployed contract becomes very convenient:

```javascript
> truffle console --network zen
truffle(zen)> const contract = await DemoToken.deployed()
truffle(zen)> contract.name()
'Demo Token'
truffle(zen)> contract.symbol()
'DEMO'
truffle(zen)> const myAccounts = await web3.eth.getAccounts()
undefined
truffle(zen)> myAccounts
[ '0x7507Cebb915af00019be3a5FE8897b2eE115B166' ]
truffle(zen)> contract.balanceOf(myAccounts[0])
BN {
  negative: 0,
  words: [ 100, <1 empty item> ],
  length: 1,
  red: null
}
truffle(zen)> contract.transfer("0x03f14683E2f95883815f0df3C9145Efe24575163", 12)
{
  tx: '0xa19ffcb54152804ed10c778828215d505656d7a112921f11e7c9ffb47c749341',
  receipt: ...,
  logs: ...
}
truffle(zen)> contract.balanceOf(myAccounts[0])
BN { negative: 0, words: [ 88, <1 empty item> ], length: 1, red: null }
```

### EOA to EOA transfer

```javascript
truffle(zen)> web3.eth.sendTransaction({ from: myAccounts[0], to: "0x03f14683E2f95883815f0df3C9145Efe24575163", value: 100 })
{
  type: '0x02',
  transactionHash: '0x8577a509da611abb479bed415677e04c7083d75d96b45f4f38ad794f8b2a0799',
  transactionIndex: 0,
  blockHash: '0x14c0a80f8d913e0433d69af367d249c4f431935911df51201e6a77aa31860a57',
  blockNumber: 3633,
  from: '0x7507cebb915af00019be3a5fe8897b2ee115b166',
  to: '0x03f14683e2f95883815f0df3c9145efe24575163',
  cumulativeGasUsed: 21000,
  gasUsed: 21000,
  logs: [],
  logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
  status: true,
  effectiveGasPrice: 2500000007
}
```

### Interacting with native smart contracts

The easiest way to access the native smart contracts with Truffle is using the Solidity interfaces:
- [contracts/ForgerStakes.sol](contracts/ForgerStakes.sol)
- [contracts/WithdrawalRequests.sol](contracts/WithdrawalRequests.sol)

#### Submit withdrawal request

Here we send some Zen to the `submitWithdrawalRequest` on the native contract for Withdrawal Requests. Note the `mcAddress` variable, which will be the address on the Zen mainchain the Zen will be withdrawn to.

```javascript
truffle compile
truffle console --network zen
truffle(zen)> const withdrawalContract = await WithdrawalRequests.at("0x0000000000000000000011111111111111111111")
undefined
truffle(zen)> const mcAddress = "0x0000000000000000000000000000000000001234"
truffle(zen)> withdrawalContract.submitWithdrawalRequest("0x0000000000000000000000000000000000001234", { value: 1000000000000 })
{
  tx: '0x07d1efe3e4cba65ae9049a456650960c6a8b8dd547c71a8db751d0deac9dd86d',
  receipt: {
    type: '0x02',
    transactionHash: '0x07d1efe3e4cba65ae9049a456650960c6a8b8dd547c71a8db751d0deac9dd86d',
    transactionIndex: 0,
    blockHash: '0xdfca20a6aeb95d43fd9d813e70ca5d9ee54bda0e96fb8a22e7d6932ddc518d14',
    blockNumber: 3637,
    from: '0x7507cebb915af00019be3a5fe8897b2ee115b166',
    to: '0x0000000000000000000011111111111111111111',
    cumulativeGasUsed: 24167,
    gasUsed: 24167,
    logs: [],
    logsBloom: '0x01000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000400000000000000000010000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000008000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000001000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000001000000000000000000000',
    status: true,
    effectiveGasPrice: 2500000007,
    rawLogs: [ [Object] ]
  },
  logs: []
}
```
