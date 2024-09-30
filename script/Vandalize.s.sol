// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { Vandalizor } from "../src/Vandalizor.sol";

contract Vandalize is BaseScript {
    function run() public broadcast {
        Vandalizor vandalizor = Vandalizor(0x1aAd9FFA78C36175B31c6ae47F50534c9c2ccC9e);
        vandalizor.vandalize{ value: 0.0003 ether }(0x5E429CCB06F1469A282b54D7B0aBc2E756d0F935);
    }
}
