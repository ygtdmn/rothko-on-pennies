// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { ROPMetadataRendererV2 } from "../src/ROPMetadataRendererV2.sol";

contract ROPMetadataRendererV2DeployTest is Test {
    function testDeploy() external {
        vm.pauseGasMetering();
        string memory endString =
            "data:image/svg+xml;base64,PHN2ZyB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczpzdmc9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2ZXJzaW9uPSIxLjEiIGlkPSJzdmcxIiB3aWR0aD0iNjgwIiBoZWlnaHQ9IjkwNCIgdmlld0JveD0iMCAwIDY4MCA5MDQiPjxkZWZzIGlkPSJkZWZzMSIvPjxnIGlkPSJnMSI+PGltYWdlIHdpZHRoPSI2ODAiIGhlaWdodD0iOTA0IiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJub25lIiBzdHlsZT0ic3Ryb2tlLXdpZHRoOjAuNTtpbWFnZS1yZW5kZXJpbmc6cGl4ZWxhdGVkIiB4bGluazpocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQVZRQUFBSEVCQU1BQUFDVTJzL0ZBQUFBRzFCTVZFVUFBQUFiR1JTak9DdklQQ1BOT0NIViYjMTA7TmlMY05pVGxPQy9zZW1JWW1ab0FBQUFBTVhSRldIUkRiMjF0Wlc1MEFGQk9SeUJsWkdsMFpXUWdkMmwwYUNCb2RIUndjem92TDJWNiYjMTA7WjJsbUxtTnZiUzl2Y0hScGNHNW4wcjNXTGdBQUFCSjBSVmgwVTI5bWRIZGhjbVVBWlhwbmFXWXVZMjl0b01PeldBQUFDRE5KUkVGVSYjMTA7ZU5ydG5ZdVZvem9NaG1saFdrZ0x0RUFMdEVBTHRKQ3k3MmkxV2oyZGtFeUdPTmUvemlFbTRNZm5uTWdXdG15bVpkbjNlYjVlSmR4MyYjMTA7UG00SjNaL25mVjlYU25lOXJ1dStVL3A0eUhXS1MrSDFSeklCZFhEVTNjbTJFWWlFR1pCRHVrK2ZjazNPTkIzZjUzalhGd2xRUjBlbCYjMTA7ck9udkw0Y1Vva0FjeXVFclJwL3p2SHdMcVk2TlZ4MmtXaFJLWEZKTERyWEtKQlF2Vm5HZWdUbzZxZ2NRMkczanEzcHZXZFp2MlRZSyYjMTA7TlM3Rm1QOEtuUy9MdG5FZXNWcSs0ajVjVjBwdDQxWHFDTlRSVWZrdlRBV1RVRkZjSUVNUkhHVkYzMWg5S0xRaTN5OFhlNDFqVTBxNSYjMTA7VHlGOTR6dFVkY3FmSzhiS0thckdMTkc4MlRhZ2pvNnFmK2J2Um5hNlhKYmxjcUZQUVpOUEQzcHBDT1hBbjlQRUtTaWtuRGxVRlpTUSYjMTA7eit3UFlCV3l0S3lBT2lpcU5PU1VMU1B5SjZ0QlZpV0d2elNGNzZ0NlJUV3NKTWVSSDhmQ0FuVjBWRFVZcUJHWGdrU2hmSk11b1llVCYjMTA7ckRtOWhZdm5SN0M5MEdNbFVJRWFVUmNqckZKeVdPaW9ldHBkS0t5cW53SnFSYk1hVmRkSWVIZ09xRURWTVN0Q2xTSzErZldId2xTRiYjMTA7V0FQYXE2R3R2by9YQXZSbWpSb3RRQVVxR3l1MkFmZEZaWld3SFlVdjBKOVp6Snd1L3lTNUErREJaYUFDbFZGcE9JQ2I4bXl1dENHdCYjMTA7Q25uVmFWWFZLMmpzY21LbHRSTVFXS0FDOWMvUTFXUWpSOFJhdGJMU1ZkRFd3TTV3VlJWOUY2Q0R3a0FGNnAvcHEwa2Y1NVpDb3RsUyYjMTA7eFZxTlZOaVNSN3liSzYzeFpmSU5xRUJsVks5QTNQUlNobnp3STJKbEZuczBub1RZTnA3b2lFMitwcGJZQ2kxaGhKV0pPcUFDVmRVcSYjMTA7R3NTSzBGSUNDOGR4dDAwd0ZTWVBET3NQSVBubkVwVEdHdGRBQmVyMXloTmlXV0gwejg5QUhFcjJBbVdiZnNIVzR2MUVuVmF3N2pCVSYjMTA7d1FRMVBBWUNkWEJVTzRnclpvdlB5Qm95MXFHaGZXUVFtOTVXTGxkWmh6UHNsREJRZ1VybUNqOEcya21IZFkxL2ZZdFNnWEhvUDIyWCYjMTA7NER1TzNHMEFGYWozVU5lVm5HRHlvSzd0Q0d3VGJ6RWl0SlVJa3FGaTdJaktiaFZBQmFwT1c3RERGcnNhK2tFTFgwaXRVdmxvSVdkdyYjMTA7Rm5iTnRjQlNPaThCQWlwUXBRdTRyVmJXcUlpRlBDLzM4bUgzaWRSYkFYVndWQm9LemtPMi9CQm1zMjFsZndSZmwwYkU2L1VkZHZGSiYjMTA7MDhGQUhSeVZISzhxWjhOWHFaQWlWVmZWTVQxM0ZVbXRnRG8wS24zVkxzQ2FMQzMxc012Rzdxdk5MZmlNNnVNbnl3cW9nNlBTZzJCMiYjMTA7SEtoUmZZWitpZUlqU3BaUjY0cW01ZUZBSFJpVllLMGpsMDVkZUFXd0tsVXRGWDhlVVhPSU9RRVZxTmZRQlVUbldSa09iamZZUjVUaSYjMTA7ZnJQZldrQU9WS0RXcUx5SU1ib1FNS2cxU0twc1c3RDNET2xidURZK1VJRWExMXVKNjFjMUNOekN1bFhNTTBybHQ2Y0JLbEQzb2d1SSYjMTA7YmdZWjgxZ25ZT005cDFZNVQ2QUMxWnNyRWZXNTdQMG1YZTBPNUxhNTRnV29RTFZ1TnRsVlMyQWZWNE02ZkVhaDJOVVdxRUMxdzJzWiYjMTA7OUZuRmVvM1lhUXUzUEJ5b2c2TldzTWVHeEk0MDRjK0NSdU1hcUVBbEIwYnZWbU9kRWQ2bFZIblFBcWhBNWEwTWRMamlaNDl0cjRRViYjMTA7VlFVcVVQTVVXM1N1ZVM5cW9WWkFIUncxTHo3c1E2M0s3WXlBT2pRcW1kYnFqQzBUd2Z2K1h0U0dweVZRQjBkbFJZcER3ZTlGSlE1KyYjMTA7VlFkUWdXclZxcGVCdFd4Y0F4V29GdFV1RytqaE1WQmdnUXJVUGJqWlZLQkFCV3AvYWpWTkdYVi91d0FWcUZVWFlLZTErbEFzTFJ1byYjMTA7UUwyUDJvTlNBUldvdFduZG8xcUZLVGFnRG8vS2c3ODlHZGFOTGdDb2c2T3lZN2gzR09oSGdBcFVkVi9rd2VCNndSZFFnZG9YYWx6WSYjMTA7QlZTZzlvemF5OEJhRFF0VW9QWUJVMjg1QTFTZ0txcmZQcUF2VkQwSEtsRHBsZHk5S0ZZYjlhOWFBWFZ3VkhudDlmc1ZxOTBGL0ZVciYjMTA7b0E2TzJwZGErUTFtdW00QmdIbzZLdjFsOXk2bHNLeUFPalRxejQzZzN6Q3NHeTBBVUlkRzllYkt6d0ZmVjVFMFpBSFV3VkgzYmlVNiYjMTA7aFFGMWROUjdFMnZ4eFJ0blRjU1ZwalZRaDBhOVoxam5sMmFkYjFvREZhaEhoaXdxekxNSDRlZ3hjRm1BT2pycXNRRUx2MVh4K2ZMQSYjMTA7ekRWUS84ZW90SjNSZlZPbFZyQ3pEQmFnQWxYZHdtdGpJYjRjNjB4blhLQUN0VmFyWXk4elBOTzkwVytwL01kY0FlcndxTzJGakdmaiYjMTA7MVNhU1VTdWdBbldYcFl6VlFzWjNPOS9RUWlDZ0FsVlJmY1A3N2swTi9TTmdVQ3VnQW5YblRXUFBVS1pvMExkTEJTcFFMV3BNZUd2USYjMTA7emQ2VGM4bUR2L09abDVpMkxqZVhIZDRlRGxTZ3V0dmtla04vYjlrQ1c3WnJZNWNjTWNYMVhMY2U1dGNrOEt2b0l1dzhVenpLazg5VSYjMTA7YVB0aXZ6VThpODhYcUVDTmYzNHFoQ0RZb00wRlVvYnJlbW5LTkYwT3lUVDVtUFRpR2dwcHkzb3FtMTY2cEkrQ1JxMkFPamdxYlJpLyYjMTA7TEQ0emlzekpNOGowbExUU1dYeitKdVhLejdWdFFBVXFON2JUUytUclcyN2R2Vnh1M2E5Rk9nS2dBcFhrdUpya291Z0tYLzBxcEtxTSYjMTA7cGppbWlrQUY2bEZVenRvVy8zVlRia0d6YXRWMy9ibVdEMVNnWnRTdnJrU05GNkFDbFZIbitmZEJzem1qNm5NN25lc0NnRG80S3IySSYjMTA7NDNkUWZiNksrbGdPUUFYcW1XcjFrNm9DRmFpQ0tnTVdRQVZxNzZoOUd0WkFCV3BHM2JhK1VYbUNHYWhBN2RsY1lkaVRoeXlBMmpIcSYjMTA7c2dBVnFKK0IycnU1QWxTZzlxOVdRQVhxcDZqVkIzVUJRRDBGdFo2MjZBTStQQVlDRmFpZjBnVUFkWERVZlFjcVVEOER0ZmZwWUtBQyYjMTA7VmFlRDJianVGWlVuMllBS1ZIMFEvQWpMQ3FoRG85THl4Y2VkQ3Mrb1duSUxCK3JncU0rbzFUbEsrSklXQUtpRG81TFlSVjYvZ3c1VSYjMTA7b01ZaGk5N05GZHJxQTZoQXhWTUFVSUVLVktEMmd2cjdsUU1xVUd2VVJ4OEV6MWxTRGxTZ1hocGJ4RlFKM3RmOGkyRU5WS0QrMnpEdyYjMTA7VitUeFRlR3FyYmZjYXppQU9qaXFPSVgxSjdRUkoxQ0JhbEY1SXF1MUFmRXIxT1BZcHJFK0RtMXhuTGFMQityZ3FINGpidW9VcEhPdyYjMTA7NTVUWWJtL3NOOUhPMnhUYmpZcTkwS2J4Y2N2a0dOOFRBUldvbnlKQUJXcnZ3cThEV1ZlZ0RvNzZId2xLNTd6YlpRZ3FBQUFBQUVsRiYjMTA7VGtTdVFtQ0MmIzEwOyIgaWQ9ImltYWdlMSIgeD0iMCIgeT0iMCIvPjwvZz48L3N2Zz4=";
        // Calculate the number of addresses based on the length of the endString
        uint256 numAddresses = (bytes(endString).length + 4) / 5;

        // Initialize an array to store the initial balances
        uint40[981] memory initialBalances;

        // Parse the endString to extract initial balances
        for (uint256 i = 0; i < numAddresses; i++) {
            uint256 startIndex = i * 5;
            uint256 remainingChars = bytes(endString).length - startIndex;
            uint256 sliceLength = remainingChars >= 5 ? 5 : remainingChars;

            // Extract a slice of the endString
            bytes memory slice = new bytes(sliceLength);
            for (uint256 j = 0; j < sliceLength; j++) {
                slice[j] = bytes(endString)[startIndex + j];
            }

            // Pad the slice if necessary and convert to uint256
            if (sliceLength < 5) {
                bytes memory paddedSlice = new bytes(5);
                for (uint256 k = 0; k < sliceLength; k++) {
                    paddedSlice[k] = slice[k];
                }
                initialBalances[i] = uint40(bytes5(paddedSlice));
            } else {
                initialBalances[i] = uint40(bytes5(slice));
            }
        }
        // Split the address array into two halves
        // Read addresses from a JSON file
        string memory addressesJson = vm.readFile("script/addresses.json");
        address[] memory addressArray = vm.parseJsonAddressArray(addressesJson, "");
        address[981] memory addresses;
        for (uint256 i = 0; i < 981; i++) {
            addresses[i] = addressArray[i];
        }
        // Create two arrays, first with 750 addresses, second with 231 addresses
        address[] memory firstArray = new address[](750);
        address[] memory secondArray = new address[](231);

        for (uint256 i = 0; i < 750; i++) {
            firstArray[i] = addressArray[i];
        }

        for (uint256 i = 0; i < 231; i++) {
            secondArray[i] = addressArray[750 + i];
        }
        vm.resumeGasMetering();

        ROPMetadataRendererV2 renderer = new ROPMetadataRendererV2(address(0x1), firstArray);
        renderer.initializeRemainingAddresses(secondArray, 750);
        renderer.initializeBalances(initialBalances);
    }
}
