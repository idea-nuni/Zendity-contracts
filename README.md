## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# Zendity Teleporter Messaging Contracts

This repository contains contracts for cross-chain messaging using Avalanche's Teleporter protocol.

## Overview

The contracts in this repository demonstrate how to send and receive messages across different Avalanche chains using the Teleporter protocol. There are two main contracts:

1. **MessageSender**: A contract for sending messages to other chains
2. **MessageReceiver**: A contract for receiving messages from other chains

These contracts work with the pre-deployed Teleporter contracts on Avalanche networks.

## Contract Addresses

Teleporter is deployed at the same address on all chains:

- **TeleporterMessenger**: `0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf`

TeleporterRegistry addresses vary by chain:

- **Mainnet C-Chain**: `0x7C43605E14F391720e1b37E49C78C4b03A488d98`
- **Fuji C-Chain**: `0xF86Cb19Ad8405AEFa7d09C778215D2Cb6eBfB228`

## Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- An Avalanche wallet with funds (for deployment)

### Installation

1. Clone this repository:
```bash
   git clone https://github.com/yourusername/zendity-teleporter.git
cd zendity-teleporter
```

2. Install dependencies:
```bash
   forge install
```

### Deployment

To deploy the contracts to Fuji testnet:

```bash
forge script script/DeployTeleporterApp.s.sol:deployFuji --rpc-url https://api.avax-test.network/ext/bc/C/rpc --private-key YOUR_PRIVATE_KEY --broadcast
```

To deploy to Mainnet:

```bash
forge script script/DeployTeleporterApp.s.sol:deployMainnet --rpc-url https://api.avax.network/ext/bc/C/rpc --private-key YOUR_PRIVATE_KEY --broadcast
```

## Usage

### Sending a Message

To send a message from one chain to another:

1. Call the `sendMessage` function on the `MessageSender` contract:
   ```solidity
   // Send a message without a fee
   sender.sendMessage(
       destinationBlockchainID, // bytes32 ID of the destination chain
       receiverAddress,         // address of the MessageReceiver on the destination chain
       "Hello from Chain A!"    // Your message
   );
   
   // Send a message with a fee (for incentivizing relayers)
   sender.sendMessageWithFee(
       destinationBlockchainID, // bytes32 ID of the destination chain
       receiverAddress,         // address of the MessageReceiver on the destination chain
       "Hello from Chain A!",   // Your message
       feeTokenAddress,         // address of the ERC20 token to use for the fee
       feeAmount                // amount of tokens to use for the fee
   );
   ```

### Receiving Messages

The `MessageReceiver` contract automatically handles incoming messages from other chains. You can query received messages using:

```solidity
// Get the number of messages received
uint256 count = receiver.getMessageCount();

// Get details of a specific message
(
    bytes32 messageID,
    bytes32 sourceBlockchainID,
    address sourceSenderAddress,
    string memory message,
    uint256 timestamp
) = receiver.getMessageByIndex(0); // Get the first message
```

## Chain IDs

To get the blockchain ID of an Avalanche chain (which is different from the EVM chain ID), you can use the following JavaScript code:

```javascript
const ethers = require('ethers');
const cb58 = require('cb58');

// Convert a chain alias (like "C", "X", etc.) to a blockchain ID
function getBlockchainID(chainAlias) {
    // Note: This is a simplified example. In production, you would query the P-Chain
    // or use the Avalanche API to get the actual blockchain ID.
    
    // Example for C-Chain on Mainnet
    if (chainAlias === "C") {
        return "0x" + Buffer.from(cb58.decode("2q9e4r6Mu3U68nU1fYjgbR6JvwrRx36CohpAX5UQxse55x1Q5")).toString('hex');
    }
}
```

## License

This project is licensed under the MIT License.
