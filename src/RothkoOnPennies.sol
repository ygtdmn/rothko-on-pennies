// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import "@manifoldxyz/creator-core-solidity/contracts/core/IERC1155CreatorCore.sol";
import "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ROPMetadataRenderer.sol";

/// @title RothkoOnPennies
/// @author @yigitduman
/// @notice An artwork that is encoded in hundreds of wallet's balances

contract RothkoOnPennies is ICreatorExtensionTokenURI, ERC165, Ownable {
    ROPMetadataRenderer metadataRenderer;
    string metadata;

    constructor(address _metadataRenderer, string memory _metadata) Ownable() {
        metadataRenderer = ROPMetadataRenderer(_metadataRenderer);
        metadata = _metadata;
    }

    function setMetadataRenderer(address _metadataRenderer) public onlyOwner {
        metadataRenderer = ROPMetadataRenderer(_metadataRenderer);
    }

    function setMetadata(string memory _metadata) public onlyOwner {
        metadata = _metadata;
    }

    function tokenURI(address, uint256) external view override returns (string memory) {
        string memory token = string(
            abi.encodePacked(
                "data:application/json;utf8,{", metadata, ', "image": "', metadataRenderer.renderMetadata(), '"}'
            )
        );

        return token;
    }

    function mint(address creatorContractAddress) external onlyOwner {
        address[] memory dest = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        string[] memory uris = new string[](1);

        dest[0] = msg.sender;
        quantities[0] = 1;

        IERC1155CreatorCore(creatorContractAddress).mintExtensionNew(dest, quantities, uris);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || super.supportsInterface(interfaceId);
    }
}
