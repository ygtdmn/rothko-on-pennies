// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

contract Vandalizor {
    function vandalize(address addr) external payable {
        // Create a new contract and send any ether sent to this function
        SoupCan newContract = new SoupCan{ value: msg.value }();

        // Immediately self destruct the new contract and send the ether to the specified address
        newContract.die(addr);
    }
}

contract SoupCan {
    constructor() payable { }

    function die(address addr) external {
        selfdestruct(payable(addr));
    }
}
