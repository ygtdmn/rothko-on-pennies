// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";

import { ROPBalanceHolder } from "../src/ROPBalanceHolder.sol";
import { ROPMetadataRendererV2 } from "../src/ROPMetadataRendererV2.sol";
import { RothkoOnPennies } from "../src/RothkoOnPennies.sol";
import { VandalizedValue } from "../src/VandalizedValue.sol";
import { console2 } from "forge-std/src/console2.sol";
import { VandalizedValueRenderer } from "../src/VandalizedValueRenderer.sol";

contract DeployVandalizedValue is BaseScript {
    function run() public broadcast {
        address metadataRendererV2 = address(0x7a9c12551e50C307c2D3EA5FFEBFb5240C660d53);
        VandalizedValueRenderer vandalizedValueRenderer = new VandalizedValueRenderer();
        string memory metadata =
            unicode"\"name\": \"Vandalized Value\",\"description\": \"A generative artwork that uses deficit balance of Rothko on Pennies to render a shattered Rothko piece. The more vandalized value increases, the more shattered the piece becomes. The token is soulbound (non-transferable) and gifted to the significant vandals.\"";
        VandalizedValue vandalizedValue =
            new VandalizedValue(metadataRendererV2, address(vandalizedValueRenderer), metadata);
        console2.log("VandalizedValue deployed at", address(vandalizedValue));
    }
}
