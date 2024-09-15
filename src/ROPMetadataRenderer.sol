// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LibString } from "solady/utils/LibString.sol";

/// @title ROPMetadataRenderer
/// @author @yigitduman
/// @notice This contract is used to collect the balances of the addresses and render them as base64 encoded image

contract ROPMetadataRenderer is Ownable {
    address[] addresses;

    constructor(address[] memory _addresses) Ownable() {
        addresses = _addresses;
    }

    function setAddresses(address[] memory _addresses) public onlyOwner {
        addresses = _addresses;
    }

    function addAddresses(address[] memory _addresses) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addresses.push(_addresses[i]);
        }
    }

    function renderMetadata() public view returns (string memory) {
        string memory concatenatedString = "";

        for (uint256 i = 0; i < addresses.length; i++) {
            uint256 balance256 = address(addresses[i]).balance;
            uint40 balance = uint40(balance256);
            bytes memory balanceByte = abi.encodePacked(balance);
            string memory balanceString = string(balanceByte);
            if (i == addresses.length - 1) {
                balanceString = LibString.slice(balanceString, 0, 2);
            }
            concatenatedString = string.concat(concatenatedString, balanceString);
        }

        return concatenatedString;
    }
}
