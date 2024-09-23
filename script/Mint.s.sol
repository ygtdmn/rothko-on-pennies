// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { ROPBalanceHolder } from "../src/ROPBalanceHolder.sol";
import { ROPMetadataRenderer } from "../src/ROPMetadataRenderer.sol";
import { RothkoOnPennies } from "../src/RothkoOnPennies.sol";

contract Mint is BaseScript {
    function run() public broadcast {
        RothkoOnPennies rop = RothkoOnPennies(0xBb38316A829DbC0559280598DBd8593801fA8471);
        rop.mint(address(0xCb337152b6181683010D07e3f00e7508cd348BC7));
    }
}
