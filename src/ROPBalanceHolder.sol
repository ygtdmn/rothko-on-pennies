// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

/// @title ROPBalanceHolder
/// @author @yigitduman
/// @notice This contract is used to hold the balance for a part of the encoded image

contract ROPBalanceHolder {
    event ImageOrder(uint16 order);

    constructor(uint256 _balance, uint16 _order) payable {
        require(msg.value == _balance, "Wrong balance");
        emit ImageOrder(_order);
    }
}
