# Rothko on Pennies

## Overview

Rothko on Pennies is a digital, fully on-chain artwork that encodes a dithered and scaled down derivative of Mark
Rothko's "Composition (1959)" into the balances of hundreds of Ethereum wallet addresses.

## Concept

The artwork is a dithered interpretation of Rothko's famous painting. Instead of being stored as a traditional image
file, the artwork data is distributed across the balances of numerous Ethereum addresses. This approach creates a
decentralized and permanent representation of the artwork on the Ethereum blockchain.

## Technical Details

- The artwork data is split into small chunks, each represented by the balance of an Ethereum address.
- A smart contract system is used to manage these addresses and render the artwork.
- The main components include:
  - `RothkoOnPennies`: Main contract, a Manifold extension that mints a token and retrieves tokenURI.
  - `ROPMetadataRenderer`: Renders the artwork by collecting balances from the storage addresses.
  - `ROPMetadataRendererV2`: An updated version with additional features like balance snapshots.
  - `ROPBalanceHolder`: Individual contracts holding parts of the encoded image data in their ETH balances.
  - `VandalizedValue`: A Manifold extension that mints soulbound "Vandalized Value" token.
  - `VandalizedValueRenderer`: Renders a generative Rothko inspired artwork that gets more glitchy as the vandalized value increases.
  - `Vandalizor`: Contract that allows users to "vandalize" the artwork by sending ETH to specific addresses.

## Viewing the Artwork

The artwork can be viewed by calling the `renderMetadata()` function on the `ROPMetadataRenderer` or
`ROPMetadataRendererV2` contract. This function collects the balances from all storage addresses and reconstructs the
image data.

## Vandalism

Users can interact with the `Vandalizor` contract to "vandalize" the artwork by sending ETH to specific addresses. This
creates a deficit balance which is used by the `VandalizedValueRenderer` to render a generative Rothko inspired piece.

## Deployed Contracts

### Mainnet

- RothkoOnPennies:
  [0xBb38316A829DbC0559280598DBd8593801fA8471](https://etherscan.io/address/0xBb38316A829DbC0559280598DBd8593801fA8471)
- ROPMetadataRenderer:
  [0xa3e4e0b234382F00a40fB4F74B570334De0Df716](https://etherscan.io/address/0xa3e4e0b234382F00a40fB4F74B570334De0Df716)
- ROPMetadataRendererV2:
  [0x7a9c12551e50C307c2D3EA5FFEBFb5240C660d53](https://etherscan.io/address/0x7a9c12551e50C307c2D3EA5FFEBFb5240C660d53)
- VandalizedValue:
  [0x85b6aac900AE881C6052D62924b1ac5E0698Fe25](https://etherscan.io/address/0x85b6aac900AE881C6052D62924b1ac5E0698Fe25)
- VandalizedValueRenderer
  [0xfE347966B763Ebb345847d38f484A48ecD189Cc4](https://etherscan.io/address/0xfE347966B763Ebb345847d38f484A48ecD189Cc4)
- Vandalizor
  [0xFecf4161A7AF6b411Bb4cbF7cCd2F55515407a48](https://etherscan.io/address/0xFecf4161A7AF6b411Bb4cbF7cCd2F55515407a48)

### Sepolia

- RothkoOnPennies:
  [0xe4519998fe1dCe6e3C2B0EF454743A3C900d1c36](https://sepolia.etherscan.io/address/0xe4519998fe1dCe6e3C2B0EF454743A3C900d1c36)
- ROPMetadataRenderer:
  [0x049dC1f57B076b3dA7De40eF132be12a6560DAB3](https://sepolia.etherscan.io/address/0x049dC1f57B076b3dA7De40eF132be12a6560DAB3)
- ROPMetadataRendererV2:
  [0xE1FD97c2cb31d0CB5784a7FcC09336671210B03C](https://sepolia.etherscan.io/address/0xE1FD97c2cb31d0CB5784a7FcC09336671210B03C)
- VandalizedValue:
  [0x1cF00d4f1D102a260Ef98c9C6c2AfBd1Ea2A37E4](https://sepolia.etherscan.io/address/0x1cF00d4f1D102a260Ef98c9C6c2AfBd1Ea2A37E4)
- VandalizedValueRenderer
  [0x641BD4923d48e5E4c907637403820FBf0A4c645a](https://sepolia.etherscan.io/address/0x641BD4923d48e5E4c907637403820FBf0A4c645a)
- Vandalizor
  [0x1aAd9FFA78C36175B31c6ae47F50534c9c2ccC9e](https://sepolia.etherscan.io/address/0x1aAd9FFA78C36175B31c6ae47F50534c9c2ccC9e)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
