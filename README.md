# Rothko on Pennies

## Overview

Rothko on Pennies is a digital, fully on-chain artwork that encodes a dithered and scaled down derivative of Mark Rothko's "Composition (1959)" into the balances of hundreds of Ethereum wallet addresses.

## Concept

The artwork is a dithered interpretation of Rothko's famous painting. Instead of being stored as a traditional image file, the artwork data is distributed across the balances of numerous Ethereum addresses. This approach creates a decentralized and permanent representation of the artwork on the Ethereum blockchain.

## Technical Details

- The artwork data is split into small chunks, each represented by the balance of an Ethereum address.
- A smart contract system is used to manage these addresses and render the artwork.
- The main components include:
  - `RothkoOnPennies`: Main contract, a Manifold extension that mints a token and retrieves tokenURI.
  - `ROPMetadataRenderer`: Renders the artwork by collecting balances from the storage addresses.
  - `ROPMetadataRendererV2`: An updated version with additional features like balance snapshots.
  - `ROPBalanceHolder`: Individual contracts holding parts of the encoded image data in their ETH balances.

## Viewing the Artwork

The artwork can be viewed by calling the `renderMetadata()` function on the `ROPMetadataRenderer` or `ROPMetadataRendererV2` contract. This function collects the balances from all storage addresses and reconstructs the image data.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
