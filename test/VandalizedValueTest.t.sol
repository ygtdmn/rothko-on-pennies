// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { LibString } from "solady/utils/LibString.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { SignedMath } from "@openzeppelin/contracts/utils/math/SignedMath.sol";

import { VandalizedValueRenderer } from "../src/VandalizedValueRenderer.sol";

contract VandalizedValueTest is Test {
    VandalizedValueRenderer renderer = new VandalizedValueRenderer();

    function testRenderSvg(uint64 value) external view {
        console2.log(renderer.renderSvg(value, true));
    }

    function testRenderSvg1() external view {
        console2.log(renderer.renderSvg(1, true));
    }

    function testRenderSvg2() external view {
        console2.log(renderer.renderSvg(100, true));
    }

    function testRenderSvg3() external view {
        console2.log(renderer.renderSvg(0.0011439804651136 ether, true));
    }

    function testRenderSvg4() external view {
        console2.log(renderer.renderSvg(4_398_046_511_360, true));
    }

    function testRenderSvg5() external view {
        console2.log(renderer.renderSvg(0.0000139804651136 ether, true));
    }

    function testRenderSvg6() external view {
        console2.log(renderer.renderSvg(0.00000839804651136 ether, true));
    }
}
