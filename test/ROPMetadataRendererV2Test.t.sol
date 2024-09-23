// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { Test } from "forge-std/src/Test.sol";
import { ROPMetadataRendererV2 } from "../src/ROPMetadataRendererV2.sol";
import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { console2 } from "forge-std/src/console2.sol";
import { RothkoOnPennies } from "../src/RothkoOnPennies.sol";

contract MockERC1155 is ERC1155 {
    constructor(address _collector) ERC1155("uri") {
        _mint(_collector, 1, 1, "");
    }
}

contract ROPMetadataRendererV2Test is Test {
    ROPMetadataRendererV2 public renderer;
    MockERC1155 public mockROP;
    address public collector;
    address public owner;
    uint40[981] public initialBalances;
    address[981] public addresses;
    string endString;

    function setUp() public {
        collector = address(0x1);
        owner = address(this);
        mockROP = new MockERC1155(collector);

        // Base64 encoded SVG string for the end of the metadata
        endString =
            "data:image/svg+xml;base64,PHN2ZyB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczpzdmc9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2ZXJzaW9uPSIxLjEiIGlkPSJzdmcxIiB3aWR0aD0iNjgwIiBoZWlnaHQ9IjkwNCIgdmlld0JveD0iMCAwIDY4MCA5MDQiPjxkZWZzIGlkPSJkZWZzMSIvPjxnIGlkPSJnMSI+PGltYWdlIHdpZHRoPSI2ODAiIGhlaWdodD0iOTA0IiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJub25lIiBzdHlsZT0ic3Ryb2tlLXdpZHRoOjAuNTtpbWFnZS1yZW5kZXJpbmc6cGl4ZWxhdGVkIiB4bGluazpocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQVZRQUFBSEVCQU1BQUFDVTJzL0ZBQUFBRzFCTVZFVUFBQUFiR1JTak9DdklQQ1BOT0NIViYjMTA7TmlMY05pVGxPQy9zZW1JWW1ab0FBQUFBTVhSRldIUkRiMjF0Wlc1MEFGQk9SeUJsWkdsMFpXUWdkMmwwYUNCb2RIUndjem92TDJWNiYjMTA7WjJsbUxtTnZiUzl2Y0hScGNHNW4wcjNXTGdBQUFCSjBSVmgwVTI5bWRIZGhjbVVBWlhwbmFXWXVZMjl0b01PeldBQUFDRE5KUkVGVSYjMTA7ZU5ydG5ZdVZvem9NaG1saFdrZ0x0RUFMdEVBTHRKQ3k3MmkxV2oyZGtFeUdPTmUvemlFbTRNZm5uTWdXdG15bVpkbjNlYjVlSmR4MyYjMTA7UG00SjNaL25mVjlYU25lOXJ1dStVL3A0eUhXS1MrSDFSeklCZFhEVTNjbTJFWWlFR1pCRHVrK2ZjazNPTkIzZjUzalhGd2xRUjBlbCYjMTA7ck9udkw0Y1Vva0FjeXVFclJwL3p2SHdMcVk2TlZ4MmtXaFJLWEZKTERyWEtKQlF2Vm5HZWdUbzZxZ2NRMkczanEzcHZXZFp2MlRZSyYjMTA7TlM3Rm1QOEtuUy9MdG5FZXNWcSs0ajVjVjBwdDQxWHFDTlRSVWZrdlRBV1RVRkZjSUVNUkhHVkYzMWg5S0xRaTN5OFhlNDFqVTBxNSYjMTA7VHlGOTR6dFVkY3FmSzhiS0thckdMTkc4MlRhZ2pvNnFmK2J2Um5hNlhKYmxjcUZQUVpOUEQzcHBDT1hBbjlQRUtTaWtuRGxVRlpTUSYjMTA7eit3UFlCV3l0S3lBT2lpcU5PU1VMU1B5SjZ0QlZpV0d2elNGNzZ0NlJUV3NKTWVSSDhmQ0FuVjBWRFVZcUJHWGdrU2hmSk11b1llVCYjMTA7ckRtOWhZdm5SN0M5MEdNbFVJRWFVUmNqckZKeVdPaW9ldHBkS0t5cW53SnFSYk1hVmRkSWVIZ09xRURWTVN0Q2xTSzErZldId2xTRiYjMTA7V0FQYXE2R3R2by9YQXZSbWpSb3RRQVVxR3l1MkFmZEZaWld3SFlVdjBKOVp6Snd1L3lTNUErREJaYUFDbFZGcE9JQ2I4bXl1dENHdCYjMTA7Q25uVmFWWFZLMmpzY21LbHRSTVFXS0FDOWMvUTFXUWpSOFJhdGJMU1ZkRFd3TTV3VlJWOUY2Q0R3a0FGNnAvcHEwa2Y1NVpDb3RsUyYjMTA7eFZxTlZOaVNSN3liSzYzeFpmSU5xRUJsVks5QTNQUlNobnp3STJKbEZuczBub1RZTnA3b2lFMitwcGJZQ2kxaGhKV0pPcUFDVmRVcSYjMTA7R3NTSzBGSUNDOGR4dDAwd0ZTWVBET3NQSVBubkVwVEdHdGRBQmVyMXloTmlXV0gwejg5QUhFcjJBbVdiZnNIVzR2MUVuVmF3N2pCVSYjMTA7d1FRMVBBWUNkWEJVTzRnclpvdlB5Qm95MXFHaGZXUVFtOTVXTGxkWmh6UHNsREJRZ1VybUNqOEcya21IZFkxL2ZZdFNnWEhvUDIyWCYjMTA7NER1TzNHMEFGYWozVU5lVm5HRHlvSzd0Q0d3VGJ6RWl0SlVJa3FGaTdJaktiaFZBQmFwT1c3RERGcnNhK2tFTFgwaXRVdmxvSVdkdyYjMTA7Rm5iTnRjQlNPaThCQWlwUXBRdTRyVmJXcUlpRlBDLzM4bUgzaWRSYkFYVndWQm9LemtPMi9CQm1zMjFsZndSZmwwYkU2L1VkZHZGSiYjMTA7MDhGQUhSeVZISzhxWjhOWHFaQWlWVmZWTVQxM0ZVbXRnRG8wS24zVkxzQ2FMQzMxc012Rzdxdk5MZmlNNnVNbnl3cW9nNlBTZzJCMiYjMTA7SEtoUmZZWitpZUlqU3BaUjY0cW01ZUZBSFJpVllLMGpsMDVkZUFXd0tsVXRGWDhlVVhPSU9RRVZxTmZRQlVUbldSa09iamZZUjVUaSYjMTA7ZnJQZldrQU9WS0RXcUx5SU1ib1FNS2cxU0twc1c3RDNET2xidURZK1VJRWExMXVKNjFjMUNOekN1bFhNTTBybHQ2Y0JLbEQzb2d1SSYjMTA7YmdZWjgxZ25ZT005cDFZNVQ2QUMxWnNyRWZXNTdQMG1YZTBPNUxhNTRnV29RTFZ1TnRsVlMyQWZWNE02ZkVhaDJOVVdxRUMxdzJzWiYjMTA7OUZuRmVvM1lhUXUzUEJ5b2c2TldzTWVHeEk0MDRjK0NSdU1hcUVBbEIwYnZWbU9kRWQ2bFZIblFBcWhBNWEwTWRMamlaNDl0cjRRViYjMTA7VlFVcVVQTVVXM1N1ZVM5cW9WWkFIUncxTHo3c1E2M0s3WXlBT2pRcW1kYnFqQzBUd2Z2K1h0U0dweVZRQjBkbFJZcER3ZTlGSlE1KyYjMTA7VlFkUWdXclZxcGVCdFd4Y0F4V29GdFV1RytqaE1WQmdnUXJVUGJqWlZLQkFCV3AvYWpWTkdYVi91d0FWcUZVWFlLZTErbEFzTFJ1byYjMTA7UUwyUDJvTlNBUldvdFduZG8xcUZLVGFnRG8vS2c3ODlHZGFOTGdDb2c2T3lZN2gzR09oSGdBcFVkVi9rd2VCNndSZFFnZG9YYWx6WSYjMTA7QlZTZzlvemF5OEJhRFF0VW9QWUJVMjg1QTFTZ0txcmZQcUF2VkQwSEtsRHBsZHk5S0ZZYjlhOWFBWFZ3VkhudDlmc1ZxOTBGL0ZVciYjMTA7b0E2TzJwZGErUTFtdW00QmdIbzZLdjFsOXk2bHNLeUFPalRxejQzZzN6Q3NHeTBBVUlkRzllYkt6d0ZmVjVFMFpBSFV3VkgzYmlVNiYjMTA7aFFGMWROUjdFMnZ4eFJ0blRjU1ZwalZRaDBhOVoxam5sMmFkYjFvREZhaEhoaXdxekxNSDRlZ3hjRm1BT2pycXNRRUx2MVh4K2ZMQSYjMTA7ekRWUS84ZW90SjNSZlZPbFZyQ3pEQmFnQWxYZHdtdGpJYjRjNjB4blhLQUN0VmFyWXk4elBOTzkwVytwL01kY0FlcndxTzJGakdmaiYjMTA7MVNhU1VTdWdBbldYcFl6VlFzWjNPOS9RUWlDZ0FsVlJmY1A3N2swTi9TTmdVQ3VnQW5YblRXUFBVS1pvMExkTEJTcFFMV3BNZUd2USYjMTA7emQ2VGM4bUR2L09abDVpMkxqZVhIZDRlRGxTZ3V0dmtla04vYjlrQ1c3WnJZNWNjTWNYMVhMY2U1dGNrOEt2b0l1dzhVenpLazg5VSYjMTA7YVB0aXZ6VThpODhYcUVDTmYzNHFoQ0RZb00wRlVvYnJlbW5LTkYwT3lUVDVtUFRpR2dwcHkzb3FtMTY2cEkrQ1JxMkFPamdxYlJpLyYjMTA7TEQ0emlzekpNOGowbExUU1dYeitKdVhLejdWdFFBVXFON2JUUytUclcyN2R2Vnh1M2E5Rk9nS2dBcFhrdUpya291Z0tYLzBxcEtxTSYjMTA7cGppbWlrQUY2bEZVenRvVy8zVlRia0d6YXRWMy9ibVdEMVNnWnRTdnJrU05GNkFDbFZIbitmZEJzem1qNm5NN25lc0NnRG80S3IySSYjMTA7NDNkUWZiNksrbGdPUUFYcW1XcjFrNm9DRmFpQ0tnTVdRQVZxNzZoOUd0WkFCV3BHM2JhK1VYbUNHYWhBN2RsY1lkaVRoeXlBMmpIcSYjMTA7c2dBVnFKK0IycnU1QWxTZzlxOVdRQVhxcDZqVkIzVUJRRDBGdFo2MjZBTStQQVlDRmFpZjBnVUFkWERVZlFjcVVEOER0ZmZwWUtBQyYjMTA7VmFlRDJianVGWlVuMllBS1ZIMFEvQWpMQ3FoRG85THl4Y2VkQ3Mrb1duSUxCK3JncU0rbzFUbEsrSklXQUtpRG81TFlSVjYvZ3c1VSYjMTA7b01ZaGk5N05GZHJxQTZoQXhWTUFVSUVLVktEMmd2cjdsUU1xVUd2VVJ4OEV6MWxTRGxTZ1hocGJ4RlFKM3RmOGkyRU5WS0QrMnpEdyYjMTA7VitUeFRlR3FyYmZjYXppQU9qaXFPSVgxSjdRUkoxQ0JhbEY1SXF1MUFmRXIxT1BZcHJFK0RtMXhuTGFMQityZ3FINGpidW9VcEhPdyYjMTA7NTVUWWJtL3NOOUhPMnhUYmpZcTkwS2J4Y2N2a0dOOFRBUldvbnlKQUJXcnZ3cThEV1ZlZ0RvNzZId2xLNTd6YlpRZ3FBQUFBQUVsRiYjMTA7VGtTdVFtQ0MmIzEwOyIgaWQ9ImltYWdlMSIgeD0iMCIgeT0iMCIvPjwvZz48L3N2Zz4=";
        // Calculate the number of addresses based on the length of the endString
        uint256 numAddresses = (bytes(endString).length + 4) / 5;

        // Read addresses from a JSON file
        string memory addressesJson = vm.readFile("script/addresses-mainnet.json");
        address[] memory addressArray = vm.parseJsonAddressArray(addressesJson, "");

        // Parse the endString to extract initial balances
        for (uint256 i = 0; i < numAddresses; i++) {
            addresses[i] = addressArray[i];

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
                vm.deal(addressArray[i], initialBalances[i]);
            } else {
                initialBalances[i] = uint40(bytes5(slice));
                vm.deal(addressArray[i], initialBalances[i]);
            }
        }

        address[] memory firstArray = new address[](750);
        address[] memory secondArray = new address[](231);

        for (uint256 i = 0; i < 750; i++) {
            firstArray[i] = addressArray[i];
        }

        for (uint256 i = 0; i < 231; i++) {
            secondArray[i] = addressArray[750 + i];
        }

        renderer = new ROPMetadataRendererV2(address(mockROP), firstArray);
        renderer.initializeRemainingAddresses(secondArray, 750);
        renderer.initializeBalances(initialBalances);
    }

    function testConstructor() public view {
        assertEq(renderer.owner(), owner);
        assertEq(address(renderer.rothkoOnPennies()), address(mockROP));
    }

    function testSetAddresses() public {
        address[981] memory newAddresses;
        for (uint256 i = 0; i < 981; i++) {
            newAddresses[i] = address(uint160(i + 1000));
        }

        vm.prank(owner);
        renderer.setAddresses(newAddresses);

        assertEq(renderer.addresses(0), address(1000));
        assertEq(renderer.addresses(980), address(1980));
    }

    function testSetInitialBalances() public {
        uint40[981] memory newBalances;
        for (uint256 i = 0; i < 981; i++) {
            newBalances[i] = uint40(i * 2000);
        }

        vm.prank(owner);
        renderer.setInitialBalances(newBalances);

        assertEq(renderer.initialBalances(0), 0);
        assertEq(renderer.initialBalances(980), 1_960_000);
    }

    function testIsCollector() public {
        vm.prank(collector);
        assertTrue(renderer.isCollector());
    }

    function testTakeSnapshot() public {
        uint256 snapshotIndexBefore = renderer.snapshotIndex();
        vm.prank(collector);
        renderer.takeSnapshot();
        assertEq(renderer.snapshotIndex(), snapshotIndexBefore + 1);
    }

    function testDeleteSnapshot() public {
        // Take a new snapshot
        vm.prank(collector);
        renderer.takeSnapshot();
        uint256 newSnapshotIndex = renderer.snapshotIndex() - 1;

        // Try to delete a snapshot as non-owner (should revert)
        vm.prank(address(0xdead));
        vm.expectRevert("Ownable: caller is not the owner");
        renderer.deleteSnapshot(newSnapshotIndex);

        // Delete the snapshot
        vm.prank(owner);
        renderer.deleteSnapshot(newSnapshotIndex);

        // Verify the snapshot has been deleted
        uint256 timestamp = renderer.snapshots(newSnapshotIndex);
        assertEq(timestamp, 0);

        // Try to delete an initial snapshot (should revert)
        vm.prank(owner);
        vm.expectRevert(ROPMetadataRendererV2.CannotDeleteInitialSnapshots.selector);
        renderer.deleteSnapshot(0);

        // Try to delete a non-existent snapshot (should revert)
        vm.prank(owner);
        vm.expectRevert(ROPMetadataRendererV2.SnapshotIndexOutOfBounds.selector);
        renderer.deleteSnapshot(100);
    }

    function testRenderMetadataFromBalances() public view {
        uint256[] memory balances = new uint256[](initialBalances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            balances[i] = initialBalances[i];
        }

        string memory metadata = renderer.renderMetadataFromBalances(balances);
        assertEq(metadata, endString);
    }

    function testRenderLiveMetadata() public view {
        string memory metadata = renderer.renderLiveMetadata();
        assertEq(metadata, endString);
    }

    function testRenderSnapshotMetadata() public {
        // Change balance of an address before taking snapshot
        address someAddress = renderer.addresses(0);
        uint256 initialBalance = renderer.initialBalances(0);
        uint256 newBalance = initialBalance + 1 ether;
        vm.deal(someAddress, newBalance);

        vm.prank(collector);
        renderer.takeSnapshot();
        uint256 snapshotIndex = renderer.snapshotIndex() - 1;

        string memory metadata = renderer.renderSnapshotMetadata(snapshotIndex);

        // The metadata should be different from the initial state
        assertTrue(keccak256(bytes(metadata)) != keccak256(bytes(endString)));

        // Reset the balance
        vm.deal(someAddress, initialBalance);
    }

    function testSetLiveSnapshotIndex() public {
        vm.prank(collector);
        renderer.takeSnapshot();
        uint256 snapshotIndex = renderer.snapshotIndex() - 1;

        vm.prank(collector);
        renderer.setLiveSnapshotIndex(snapshotIndex);
        assertEq(renderer.liveSnapshotIndex(), snapshotIndex);
        assertFalse(renderer.showLiveData());
    }

    function testToggleLiveData() public {
        vm.prank(collector);
        renderer.setShowLiveData(false);
        assertFalse(renderer.showLiveData());

        vm.prank(collector);
        renderer.setShowLiveData(true);
        assertTrue(renderer.showLiveData());
    }

    function testRenderMetadata() public {
        // Change balance of an address before taking snapshot
        address someAddress = renderer.addresses(0);
        uint256 initialBalance = renderer.initialBalances(0);
        uint256 newBalance = initialBalance + 1 ether;
        vm.deal(someAddress, newBalance);

        // Test with showLiveData = false
        vm.prank(collector);
        renderer.setShowLiveData(false);
        vm.prank(collector);
        renderer.takeSnapshot();
        uint256 snapshotIndex = renderer.snapshotIndex() - 1;
        vm.prank(collector);
        renderer.setLiveSnapshotIndex(snapshotIndex);

        string memory metadata = renderer.renderMetadata();
        assertTrue(keccak256(bytes(metadata)) != keccak256(bytes(endString)));

        // Test with showLiveData = true
        vm.prank(collector);
        renderer.setShowLiveData(true);

        metadata = renderer.renderMetadata();
        assertTrue(keccak256(bytes(metadata)) != keccak256(bytes(endString)));

        // Reset the balance
        vm.deal(someAddress, initialBalance);

        metadata = renderer.renderMetadata();
        assertEq(metadata, endString);
    }

    function testOnlyCollectorModifier() public {
        vm.expectRevert(ROPMetadataRendererV2.NotCollector.selector);
        renderer.setLiveSnapshotIndex(0);

        vm.prank(collector);
        renderer.setLiveSnapshotIndex(0);
    }

    function testOnlyCollectorOrOwnerModifier() public {
        vm.prank(address(0x66));
        vm.expectRevert(ROPMetadataRendererV2.NotCollector.selector);
        renderer.takeSnapshot();

        vm.prank(collector);
        renderer.takeSnapshot();

        vm.prank(owner);
        renderer.takeSnapshot();
    }

    function testRenderNonExistentSnapshot() public {
        uint256 nonExistentIndex = 999;
        vm.expectRevert(ROPMetadataRendererV2.SnapshotIndexOutOfBounds.selector);
        renderer.renderSnapshotMetadata(nonExistentIndex);
    }

    function testSetLiveSnapshotIndexOutOfBounds() public {
        uint256 nonExistentIndex = 999;
        vm.prank(collector);
        vm.expectRevert(ROPMetadataRendererV2.SnapshotIndexOutOfBounds.selector);
        renderer.setLiveSnapshotIndex(nonExistentIndex);
    }

    function countAddresses() private view returns (uint256) {
        uint256 count = 0;
        while (true) {
            try renderer.addresses(count) returns (address) {
                count++;
            } catch {
                break;
            }
        }
        return count;
    }

    function testInitialSnapshots() public view {
        uint256[] memory balances = renderer.getSnapshotBalances(0);
        uint256 timestamp = renderer.snapshots(0);
        assertEq(timestamp, 1_726_612_919);
        assertEq(balances.length, initialBalances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            if (i == 838) {
                assertEq(balances[i], initialBalances[i] + 256);
            } else {
                assertEq(balances[i], initialBalances[i]);
            }
        }
    }

    function testTakeSnapshotAddsNewSnapshot() public {
        uint256 initialSnapshotCount = getSnapshotCount();

        vm.prank(collector);
        renderer.takeSnapshot();

        uint256 newSnapshotCount = getSnapshotCount();
        assertEq(newSnapshotCount, initialSnapshotCount + 1, "Snapshot count should increase by 1");

        uint256[] memory balances = renderer.getSnapshotBalances(newSnapshotCount - 1);
        uint256 timestamp = renderer.snapshots(newSnapshotCount - 1);
        assertEq(balances.length, 981);
        assertEq(timestamp, block.timestamp);
    }

    function getSnapshotCount() private view returns (uint256) {
        uint256 count = 0;
        while (true) {
            try renderer.snapshots(count) returns (uint256 result) {
                if (result == 0) {
                    break;
                }
                count++;
            } catch {
                break;
            }
        }
        return count;
    }

    function testGetDeficitBalanceFromTheInitialSnapshot() public {
        // Set up initial balances
        uint256 totalInitialBalance = 0;
        for (uint256 i = 0; i < initialBalances.length; i++) {
            totalInitialBalance += uint256(initialBalances[i]);
        }

        // Simulate changes in live balances
        uint256 totalLiveBalance = 0;
        uint256 addressesLength = countAddresses();
        for (uint256 i = 0; i < addressesLength; i++) {
            address addr = renderer.addresses(i);
            uint256 newBalance = uint256(initialBalances[i]) + 1; // Increase each balance by 1
            vm.deal(addr, newBalance);
            totalLiveBalance += newBalance;
        }

        uint256 expectedDeficit = totalLiveBalance - totalInitialBalance;

        uint256 actualDeficit = renderer.getDeficitBalanceFromTheInitialSnapshot();

        assertEq(actualDeficit, expectedDeficit, "Deficit balance calculation is incorrect");
    }

    function testCreateCustomSnapshot() public {
        uint256[] memory balanceChanges = new uint256[](2);
        balanceChanges[0] = 100;
        balanceChanges[1] = 200;
        uint256[] memory balanceChangeIndexes = new uint256[](2);
        balanceChangeIndexes[0] = 0;
        balanceChangeIndexes[1] = 1;

        vm.prank(owner);
        renderer.createCustomSnapshot(block.timestamp, balanceChanges, balanceChangeIndexes);

        uint256[] memory snapshotBalances = renderer.getSnapshotBalances(renderer.snapshotIndex() - 1);
        assertEq(snapshotBalances[0], initialBalances[0] + 100);
        assertEq(snapshotBalances[1], initialBalances[1] + 200);
        assertEq(renderer.snapshots(renderer.snapshotIndex() - 1), block.timestamp);
    }

    function testCreateCustomSnapshotMismatchedArrays() public {
        uint256[] memory balanceChanges = new uint256[](2);
        uint256[] memory balanceChangeIndexes = new uint256[](1);

        vm.prank(owner);
        vm.expectRevert(ROPMetadataRendererV2.MismatchedArrayLengths.selector);
        renderer.createCustomSnapshot(block.timestamp, balanceChanges, balanceChangeIndexes);
    }

    function testRenderSnapshotMetadataNotTaken() public {
        uint256 nonExistentIndex = renderer.snapshotIndex();
        vm.expectRevert(ROPMetadataRendererV2.SnapshotIndexOutOfBounds.selector);
        renderer.renderSnapshotMetadata(nonExistentIndex);
    }

    function testGetSnapshotBalancesNotTaken() public {
        uint256 nonExistentIndex = renderer.snapshotIndex();
        vm.expectRevert(ROPMetadataRendererV2.SnapshotIndexOutOfBounds.selector);
        renderer.getSnapshotBalances(nonExistentIndex);
    }

    function testRenderMetadataShowLiveData() public {
        vm.prank(collector);
        renderer.setShowLiveData(true);
        string memory liveMetadata = renderer.renderLiveMetadata();
        string memory renderedMetadata = renderer.renderMetadata();
        assertEq(renderedMetadata, liveMetadata);
    }

    function testRenderMetadataShowSnapshot() public {
        vm.prank(collector);
        renderer.takeSnapshot();
        uint256 newSnapshotIndex = renderer.snapshotIndex() - 1;

        vm.prank(collector);
        renderer.setShowLiveData(false);
        vm.prank(collector);
        renderer.setLiveSnapshotIndex(newSnapshotIndex);

        string memory snapshotMetadata = renderer.renderSnapshotMetadata(newSnapshotIndex);
        string memory renderedMetadata = renderer.renderMetadata();
        assertEq(renderedMetadata, snapshotMetadata);
    }

    function testOnlyOwnerModifier() public {
        address nonOwner = address(0x123);
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        renderer.setAddresses(addresses);
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        renderer.setInitialBalances(initialBalances);
        uint256[] memory balanceChanges = new uint256[](1);
        uint256[] memory balanceChangeIndexes = new uint256[](1);
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        renderer.createCustomSnapshot(block.timestamp, balanceChanges, balanceChangeIndexes);
        vm.prank(nonOwner);
        vm.expectRevert(ROPMetadataRendererV2.NotCollector.selector);
        renderer.setLiveSnapshotIndex(0);
        vm.prank(nonOwner);
        vm.expectRevert(ROPMetadataRendererV2.NotCollector.selector);
        renderer.setShowLiveData(true);
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        renderer.deleteSnapshot(0);
    }

    function testTakeSnapshotOnlyCollectorOrOwner() public {
        address nonCollectorOrOwner = address(0x123);
        vm.prank(nonCollectorOrOwner);
        vm.expectRevert(ROPMetadataRendererV2.NotCollector.selector);
        renderer.takeSnapshot();
    }

    function testRenderMetadataFromBalancesEdgeCases() public view {
        uint256[] memory balances = new uint256[](2);
        balances[0] = 0;
        balances[1] = type(uint40).max;

        string memory result = renderer.renderMetadataFromBalances(balances);
        assertEq(bytes(result).length, 7); // 5 bytes for first balance + 2 bytes for second balance
    }

    function testGetDeficitBalanceFromTheInitialSnapshot2() public {
        uint256 initialDeficit = renderer.getDeficitBalanceFromTheInitialSnapshot();
        assertEq(initialDeficit, 0);

        // Change some balances
        for (uint256 i = 0; i < 5; i++) {
            address addr = renderer.addresses(i);
            uint256 newBalance = uint256(renderer.initialBalances(i)) + 1 ether;
            vm.deal(addr, newBalance);
        }

        uint256 newDeficit = renderer.getDeficitBalanceFromTheInitialSnapshot();
        assertEq(newDeficit, 5 ether);
    }
}
