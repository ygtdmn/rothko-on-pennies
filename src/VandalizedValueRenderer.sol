// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { LibString } from "solady/utils/LibString.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { SignedMath } from "@openzeppelin/contracts/utils/math/SignedMath.sol";

/// @title VandalizedValueRenderer
/// @notice Contract for rendering a "vandalized value" as an SVG image
contract VandalizedValueRenderer {
    using LibString for uint256;

    // --- Constants for constructing the SVG image in parts ---

    /// @notice First part of the SVG string defining the SVG structure, clip path, and first turbulence filter
    string private constant SVG_PART_1 =
        '<svg xmlns="http://www.w3.org/2000/svg" width="575" height="825"><defs><clipPath id="a"><path d="M28.75 25h517.5v700H28.75z"/></clipPath><filter id="b"><feTurbulence type="fractalNoise" baseFrequency=".02" numOctaves="3" seed="1" result="noise"/><feDisplacementMap in="SourceGraphic" in2="noise" scale="';

    /// @notice Second part of the SVG string defining the second turbulence filter and displacement map
    string private constant SVG_PART_2 =
        '" xChannelSelector="R" yChannelSelector="G" result="shift1"/><feTurbulence type="fractalNoise" baseFrequency=".05" numOctaves="2" seed="2" result="noise2"/><feDisplacementMap in="shift1" in2="noise2" scale="';

    /// @notice Third part of the SVG string defining the blend and color matrix filter
    string private constant SVG_PART_3 =
        '" xChannelSelector="R" yChannelSelector="B" result="shift2"/><feBlend in="shift1" in2="shift2" mode="screen" result="blend"/><feColorMatrix in="blend" values="';

    /// @notice Fourth part of the SVG string defining the text elements to display the vandalized value
    string private constant SVG_PART_4 =
        '" result="colorShift"/></filter></defs><path fill="#0a0a0a" d="M0 0h575v825H0z"/><g filter="url(#b)" clip-path="url(#a)"><path fill="#3a3a3a" d="M28.75 25h517.5v500H28.75z"/><path fill="#5a5a5a" d="M28.75 550h517.5v175H28.75z"/></g><path fill="none" stroke="#1a1a1a" stroke-width="2" filter="url(#e)" d="M28.75 25h517.5v700H28.75z"/><path stroke="#4a4a4a" d="M28.75 750h517.5"/><g id="d" font-family="\'Courier New\', monospace" font-size="17.5" fill="#b0b0b0"><text x="42.5" y="787.5">Vandalized Value:</text><text id="c" x="532.5" y="787.5" text-anchor="end">';

    /// @notice Fifth part of the SVG string closing out the SVG tags
    string private constant SVG_PART_5 =
        ' ETH</text></g><defs><filter id="e" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur in="SourceAlpha" stdDeviation="3"/><feOffset result="offsetblur"/><feComponentTransfer><feFuncA type="linear" slope=".2"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs></svg>';

    /// @notice Render the vandalized value as an SVG image
    /// @param value The vandalized value to render (in wei)
    /// @param base64Encoded Whether to return the SVG as a base64 encoded string
    /// @return The SVG image string
    function renderSvg(uint256 value, bool base64Encoded) public pure returns (string memory) {
        string memory valueString = formatEther(value);

        // Calculate chaos factor based on value
        int256 chaosFactor = int256(calculateChaosFactor(value));

        // Calculate SVG filter parameters based on chaos factor
        int256 scale1 = SignedMath.max(5 + (45 * chaosFactor) / 1e18, 0);
        int256 scale2 = SignedMath.max(3 + (27 * chaosFactor) / 1e18, 0);
        int256 colorShift = SignedMath.max(1050 + (150 * chaosFactor) / 1e18, 0);
        int256 colorShiftInverse = SignedMath.max(950 - (150 * chaosFactor) / 1e18, 0);

        // Construct color matrix filter string
        string memory colorMatrix = string(
            abi.encodePacked(
                LibString.toString(int256(colorShift) / 1000),
                " 0 0 0 0 0 ",
                LibString.toString(int256(colorShiftInverse) / 1000),
                " 0 0 0 0 0 ",
                LibString.toString(int256(colorShiftInverse) / 1000),
                " 0 0 0 0 0 1 0"
            )
        );

        // Construct final SVG string
        string memory finalSvg = string(
            abi.encodePacked(
                SVG_PART_1,
                LibString.toString(int256(scale1)),
                SVG_PART_2,
                LibString.toString(int256(scale2)),
                SVG_PART_3,
                colorMatrix,
                SVG_PART_4,
                valueString,
                SVG_PART_5
            )
        );

        // Return SVG as base64 encoded if requested, otherwise return plain SVG
        if (base64Encoded) {
            return Base64.encode(bytes(finalSvg), false, false);
        }
        return finalSvg;
    }

    /// @notice Calculate the "chaos factor" used to determine SVG filter parameters
    /// @param value The vandalized value (in wei)
    /// @return The chaos factor
    function calculateChaosFactor(uint256 value) public pure returns (uint256) {
        // Cap value at 10,000 ether
        if (value > 10_000 ether) {
            value = 10_000 ether;
        }

        // Define fixed point constants using PRBMath
        SD59x18 g = value > 4e12 ? sd(int256(value)) : sd(4e12); // 4e12 represents 4e-6
        SD59x18 f = sd(4e12); // 4e-6
        SD59x18 d = sd(1e17); // 0.1
        SD59x18 c = sd(3e18); // 3
        SD59x18 b = sd(25e18); // 25

        // Calculate 'a' using logarithms
        SD59x18 numerator = g.ln().sub(f.ln());
        SD59x18 denominator = d.ln().sub(f.ln());
        SD59x18 a = numerator.div(denominator);

        // Calculate chaos factor 'j'
        SD59x18 j = c.add(b.sub(c).mul(a));

        return uint256(j.intoUint256()); // Convert back to uint256
    }

    /// @notice Format a wei value as an ether string with 18 decimal places
    /// @param value The value in wei
    /// @return The formatted ether string
    function formatEther(uint256 value) public pure returns (string memory) {
        // Convert value to ether
        uint256 etherValue = value / 1e18;

        // Convert ether value to string
        string memory etherString = etherValue.toString();

        // Add decimal point and remaining wei as decimal places
        uint256 remainingWei = value % 1e18;
        if (remainingWei != 0) {
            string memory decimalString = remainingWei.toString();

            // Pad decimal part with leading zeros to ensure 18 decimal places
            uint256 decimalLength = bytes(decimalString).length;
            if (decimalLength < 18) {
                decimalString = string(abi.encodePacked(LibString.repeat("0", 18 - decimalLength), decimalString));
            }

            etherString = string(abi.encodePacked(etherString, ".", decimalString));
        } else {
            // If there are no remaining wei, add 18 zeros after the decimal point
            etherString = string(abi.encodePacked(etherString, ".000000000000000000"));
        }

        return etherString;
    }
}
