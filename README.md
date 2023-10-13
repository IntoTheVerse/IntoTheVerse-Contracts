# IntoTheVerse Contracts

![image](https://github.com/IntoTheVerse/IntoTheVerse-Contracts/assets/43913734/c7875205-8547-48ce-89e9-24389fb0355c)


This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
# IntoTheVerse-Contracts


# IntoTheVerse-Contracts Smart Contracts

## Overview

This repository contains smart contracts for the IntoTheVerse-Contracts project deployed on the CELO network. The project includes the following smart contracts:

1. **TreeContract**: An NFT contract that represents trees. Trees can be watered, and they have levels and a decay rate.
2. **GreenDonation**: A staking contract that allows nurturing of trees by staking authorized ERC20 tokens.
3. **Marketplace**: A marketplace contract for auctioning and bidding of trees (To be implemented).
4. **SwapRouter**: A swapping router for tokens, supporting both Uniswap V3 and Ubeswap V2.

Each contract serves a different role in the ecosystem and is built using Solidity. The project leverages OpenZeppelin libraries for standard functionalities like ownership and ERC standards.


## Installation

Setting up the development environment to deploy and interact with the smart contracts involves a few steps. Below is a step-by-step guide to get you up and running:

1. **Clone the Repository**: Clone the IntoTheVerse-Contracts repository to your local machine.

    ```bash
    git clone <repository_url>
    ```

2. **Navigate to Project Folder**: Open a terminal and navigate to the project folder.

    ```bash
    cd IntoTheVerse-Contracts
    ```

3. **Install Node.js Packages**: Use npm to install the required Node.js packages.

    ```bash
    npm install
    ```

4. **Install Hardhat**:

    ```bash
    npm install --save-dev hardhat
    ```

5. **Compile Smart Contracts**:

    ```bash
    npx hardhat compile
    ```

6. **Deploy Contracts**:

    ```bash
    npx hardhat run scripts/deploy.js --network <network_name>
    ```

7. **Interact with Contracts**: Use Hardhat tasks or scripts to interact with the deployed contracts.

### Note

- Replace `<repository_url>` with the actual repository URL.
- Replace `<network_name>` with the desired blockchain network (e.g., `mainnet`, `ropsten`, `alfajores` for CELO).

For more specific instructions related to each smart contract, refer to the **Usage** section.



## Incoming Features

The project is under active development, and the following features are slated for implementation:

### Marketplace Contract

- **Auction Functionality**: Users will be able to auction their trees.
- **Bid Functionality**: Users will be able to place bids on trees.
- **Offer Functionality**: Trees can be offered for a fixed price.
- **List Functionality**: Listing trees for sale or auction.
- **Accept Offer Functionality**: Sellers can accept offers made on their trees.

### GreenDonation Contract

- **Toucan Protocol Integration**: 10% of the yield will be sent to the Toucan Protocol.
  
### SwapRouter Contract

- **MENTO Protocol Integration**: Allow swaps using the MENTO protocol.



## Toucan Requirement Certificates

The GreenDonation contract is designed to integrate with the Toucan Protocol. More details can be found [here](https://docs.toucan.earth/toucan/dev-resources/smart-contracts/retirement-certificates).
