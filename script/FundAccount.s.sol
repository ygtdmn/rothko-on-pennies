// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { BaseScript } from "./Base.s.sol";

contract FundAccountScript is BaseScript {
    function run() external broadcast {
        (broadcaster,) = deriveRememberKey({ mnemonic: TEST_MNEMONIC, index: 0 });
        address recipient = 0x28996f7DECe7E058EBfC56dFa9371825fBfa515A;
        uint256 amount = 10 ether;

        vm.stopBroadcast();
        vm.startBroadcast(broadcaster);
        payable(recipient).transfer(amount);
    }
}
