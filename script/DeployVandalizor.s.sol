// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { Vandalizor } from "../src/Vandalizor.sol";

contract DeployVandalizor is BaseScript {
    function run() public broadcast {
        new Vandalizor();
    }
}
