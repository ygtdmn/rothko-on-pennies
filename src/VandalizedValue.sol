// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { IERC721CreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import { IERC1155CreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/IERC1155CreatorCore.sol";
import { ICreatorExtensionTokenURI } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";
import { IERC1155CreatorExtensionApproveTransfer } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ERC1155/IERC1155CreatorExtensionApproveTransfer.sol";
import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import "./ROPMetadataRendererV2.sol";
import "./VandalizedValueRenderer.sol";

/// @title VandalizedValue
/// @author @yigitduman
/// @notice An artwork that uses deficit balance of Rothko on Pennies to render a generative, shattered Rothko piece. The
/// soulbound token is to be gifted to the vandals.

contract VandalizedValue is ICreatorExtensionTokenURI, IERC1155CreatorExtensionApproveTransfer, ERC165, Ownable {
    /// @notice Instance of the ROPMetadataRendererV2 contract for fetching deficit balance
    ROPMetadataRendererV2 public metadataRendererV2;

    /// @notice Instance of the VandalizedValueRenderer contract for rendering SVGs
    VandalizedValueRenderer public renderer;

    /// @notice Metadata string to be included in the token URI
    string public metadata;

    /// @notice Constructor to initialize the contract
    /// @param _metadataRendererV2 Address of the ROPMetadataRendererV2 contract
    /// @param _renderer Address of the VandalizedValueRenderer contract
    /// @param _metadata Initial metadata string
    constructor(address _metadataRendererV2, address _renderer, string memory _metadata) Ownable() {
        metadataRendererV2 = ROPMetadataRendererV2(_metadataRendererV2);
        renderer = VandalizedValueRenderer(_renderer);
        metadata = _metadata;
    }

    /// @notice Set a new metadata renderer
    /// @param _metadataRendererV2 Address of the new ROPMetadataRendererV2 contract
    /// @dev Only callable by the contract owner
    function setMetadataRenderer(address _metadataRendererV2) public onlyOwner {
        metadataRendererV2 = ROPMetadataRendererV2(_metadataRendererV2);
    }

    /// @notice Set a new SVG renderer
    /// @param _renderer Address of the new VandalizedValueRenderer contract
    /// @dev Only callable by the contract owner
    function setRenderer(address _renderer) public onlyOwner {
        renderer = VandalizedValueRenderer(_renderer);
    }

    /// @notice Set new metadata
    /// @param _metadata New metadata string
    /// @dev Only callable by the contract owner
    function setMetadata(string memory _metadata) public onlyOwner {
        metadata = _metadata;
    }

    /// @notice Generate the token URI for a given token
    /// @dev Implements ICreatorExtensionTokenURI.tokenURI
    /// @return Token URI as a string
    function tokenURI(address, uint256) external view override returns (string memory) {
        string memory token = string(
            abi.encodePacked(
                "data:application/json;utf8,{",
                metadata,
                ', "image": "data:image/svg+xml;base64,',
                renderer.renderSvg(metadataRendererV2.getDeficitBalanceFromTheInitialSnapshot(), true),
                '"}'
            )
        );

        return token;
    }

    /// @notice Mint a new token
    /// @param creatorContractAddress Address of the creator contract (ERC1155)
    /// @param to Addresses to mint the token to
    /// @dev Only callable by the contract owner
    function mint(address creatorContractAddress, address[] calldata to) external onlyOwner {
        string[] memory uris = new string[](to.length);
        uint256[] memory quantities = new uint256[](to.length);
        for (uint256 i = 0; i < to.length; i++) {
            quantities[i] = 1;
        }

        IERC1155CreatorCore(creatorContractAddress).mintExtensionNew(to, quantities, uris);
    }

    /// @notice Check if the contract supports a given interface
    /// @param interfaceId The interface identifier
    /// @return bool True if the contract supports the interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId
            || interfaceId == type(IERC1155CreatorExtensionApproveTransfer).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function setApproveTransfer(address creator, bool enabled) external override {
        require(
            ERC165Checker.supportsInterface(creator, type(IERC1155CreatorCore).interfaceId),
            "creator must implement IERC1155CreatorCore"
        );
        IERC1155CreatorCore(creator).setApproveTransferExtension(enabled);
    }

    function approveTransfer(
        address,
        address,
        address,
        uint256[] calldata,
        uint256[] calldata
    )
        external
        pure
        override
        returns (bool)
    {
        return false;
    }
}
