 
# Zendity-contracts

**Universal identity across Avax L1s.**  
A Solidity smart contract suite that enables universal identity on Avalanche Layer 1 blockchains by accepting zk identity proofs from external sources and synchronizing them across Avax L1 chains.
![Screenshot 2025-05-25 at 9 05 03 AM](https://github.com/user-attachments/assets/83793342-5927-4c92-a66e-182e7d0f36a1)


## Features

- 100% Solidity codebase, designed for Avalanche L1
- Supports cross-L1s and multi-app identity authentication

## Protocal Used 
- CCIP fron Chainlink
- ICM from Avalanche

## Project Goals

Zendity-contracts aims to simplify user identity creation, management, and verification within the Avalanche ecosystem. It provides a standardized and extensible set of smart contracts so identity data can be easily shared and verified across various DApps and services.

## Usage

1. **Contract Deployment**  
   - Refer to the Solidity files in the `contracts/` directory and deploy the relevant contracts according to your needs.

2. **Integration**  
   - Call the contract interfaces from your DApp to enable authentication and identity-related features.

3. **Testing**  
   - It is recommended to deploy and test contracts on Avalanche testnets (such as Fuji) before mainnet deployment.

## Directory Structure

```
contracts/    # Solidity smart contracts
scripts/      # Deployment and interaction scripts
README.md     # Project documentation
...
```

## Contributing

Contributions are welcome!

1. Fork this repository
2. Create a new branch for your feature or fix
3. Submit a Pull Request

## License

This project is licensed under the MIT License.

---

Feel free to add more specific usage instructions, API documentation, or examples as needed!
