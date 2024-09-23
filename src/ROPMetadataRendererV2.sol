// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { LibString } from "solady/utils/LibString.sol";

/// @title ROPMetadataRendererV2
/// @author @yigitduman
/// @notice This contract is used to collect the balances of addresses and render them as base64 encoded image
/// @dev This is an updated version of the ROPMetadataRenderer contract
/// @dev Changes include:
/// @dev - Added support for snapshotting the balances of the addresses
/// @dev - Added getDeficitBalanceFromTheInitialSnapshot
/// @dev - Added documentation
contract ROPMetadataRendererV2 is Ownable {
    /// @notice Struct to store balance changes for a snapshot
    struct BalanceSnapshot {
        mapping(uint256 => uint256) balanceChanges;
        uint256 snapshotTimestamp;
    }

    /// @notice Event emitted when a snapshot is taken
    event SnapshotTaken(uint256 snapshotIndex, uint256 timestamp);
    /// @notice Event emitted when a snapshot is deleted
    event SnapshotDeleted(uint256 snapshotIndex);
    /// @notice Event emitted when the live snapshot index is set
    event LiveSnapshotIndexSet(uint256 liveSnapshotIndex);
    /// @notice Event emitted when the show live data flag is set
    event ShowLiveDataSet(bool showLiveData);

    /// @notice Error thrown when a non-collector tries to perform a collector-only action
    error NotCollector();
    /// @notice Error thrown when trying to access a snapshot index that doesn't exist
    error SnapshotIndexOutOfBounds();
    /// @notice Error thrown when trying to delete initial snapshots
    error CannotDeleteInitialSnapshots();
    /// @notice Error thrown when trying to access a snapshot that doesn't exist
    error SnapshotNotTaken();
    /// @notice Error thrown when trying to set an invalid address array
    error InvalidAddressArrayLength();
    /// @notice Error thrown when trying to set an invalid initial balances array
    error InvalidInitialBalancesArrayLength();
    /// @notice Error thrown when trying to create a snapshot with mismatched array lengths
    error MismatchedArrayLengths();

    /// @notice Mapping to store balance snapshots
    mapping(uint256 => BalanceSnapshot) public snapshots;
    uint256 public snapshotIndex;

    /// @notice Mapping to store initial balances
    uint40[981] public initialBalances;

    /// @notice Mapping to store addresses
    address[981] public addresses;

    /// @notice Address of the RothkoOnPennies contract
    IERC721 public immutable rothkoOnPennies;

    /// @notice Index of the current live snapshot
    uint256 public liveSnapshotIndex;

    /// @notice Boolean to toggle live data visibility
    bool public showLiveData = true;

    /// @notice Constructor to initialize the contract with the RothkoOnPennies contract address
    /// @param _rothkoOnPennies Address of the RothkoOnPennies contract
    constructor(address _rothkoOnPennies, address[] memory partialAddresses) Ownable() {
        rothkoOnPennies = IERC721(_rothkoOnPennies);
        uint256 partialAddressesLength = partialAddresses.length;
        for (uint256 i = 0; i < partialAddressesLength; i++) {
            addresses[i] = partialAddresses[i];
        }
    }

    /// @notice Initialize the contract with addresses
    /// @param _addresses Array of addresses to set
    function initializeRemainingAddresses(address[] calldata _addresses, uint256 startIndex) public onlyOwner {
        uint256 _addressesLength = _addresses.length;
        for (uint256 i = 0; i < _addressesLength; i++) {
            addresses[startIndex + i] = _addresses[i];
        }
    }

    /// @notice Initialize the contract with initial balances
    /// @param _initialBalances Array of initial balances for the addresses
    function initializeBalances(uint40[981] memory _initialBalances) public onlyOwner {
        initialBalances = _initialBalances;
        // Initialize Takens Theorem snapshot
        uint256[] memory balanceChanges = new uint256[](1);
        balanceChanges[0] = 256;
        uint256[] memory balanceChangeIndexes = new uint256[](1);
        balanceChangeIndexes[0] = 838;
        createCustomSnapshot(1_726_612_919, balanceChanges, balanceChangeIndexes);
    }

    /// @notice Set new addresses
    /// @param _addresses Array of addresses to set
    function setAddresses(address[981] memory _addresses) public onlyOwner {
        if (_addresses.length != 981) revert InvalidAddressArrayLength();
        addresses = _addresses;
    }

    /// @notice Set initial balances for addresses
    /// @param _initialBalances Array of initial balances for the addresses
    function setInitialBalances(uint40[981] memory _initialBalances) public onlyOwner {
        if (_initialBalances.length != 981) revert InvalidInitialBalancesArrayLength();
        initialBalances = _initialBalances;
    }

    /// @notice Get the address of the current collector
    /// @return Address of the current collector (owner of token ID 1)
    function getCollector() public view returns (address) {
        return rothkoOnPennies.ownerOf(1);
    }

    /// @notice Modifier to restrict function access to only the collector
    modifier onlyCollector() {
        if (msg.sender != getCollector()) revert NotCollector();
        _;
    }

    /// @notice Modifier to restrict function access to either the collector or the contract owner
    modifier onlyCollectorOrOwner() {
        if (msg.sender != getCollector() && msg.sender != owner()) revert NotCollector();
        _;
    }

    /// @notice Take a snapshot of the current balance changes
    function takeSnapshot() public onlyCollectorOrOwner {
        BalanceSnapshot storage newSnapshot = snapshots[snapshotIndex];
        newSnapshot.snapshotTimestamp = block.timestamp;

        uint256 addressCount = addresses.length;
        for (uint256 i = 0; i < addressCount; i++) {
            address addr = addresses[i];
            uint256 balanceChange = address(addr).balance - uint256(initialBalances[i]);
            if (balanceChange != 0) {
                newSnapshot.balanceChanges[i] = balanceChange;
            }
        }

        emit SnapshotTaken(snapshotIndex, block.timestamp);
        snapshotIndex++;
    }

    /// @notice Delete a snapshot by setting it to an empty struct
    /// @param snapshotIndex_ Index of the snapshot to delete
    /// @dev Cannot delete snapshots at index 0 (initial snapshot)
    function deleteSnapshot(uint256 snapshotIndex_) public onlyOwner {
        if (snapshotIndex_ >= snapshotIndex) revert SnapshotIndexOutOfBounds();
        if (snapshotIndex_ < 1) revert CannotDeleteInitialSnapshots();
        delete snapshots[snapshotIndex_];
        emit SnapshotDeleted(snapshotIndex_);
    }

    /// @notice Create a custom snapshot with specified balance changes
    /// @param timestamp The timestamp for the snapshot
    /// @param balanceChanges Array of balance changes for each address
    /// @param balanceChangeIndexes Array of indexes for balance changes
    function createCustomSnapshot(
        uint256 timestamp,
        uint256[] memory balanceChanges,
        uint256[] memory balanceChangeIndexes
    )
        public
        onlyOwner
    {
        if (balanceChanges.length != balanceChangeIndexes.length) revert MismatchedArrayLengths();
        BalanceSnapshot storage newSnapshot = snapshots[snapshotIndex];
        newSnapshot.snapshotTimestamp = timestamp;
        for (uint256 i = 0; i < balanceChanges.length; i++) {
            if (balanceChanges[i] != 0) {
                newSnapshot.balanceChanges[balanceChangeIndexes[i]] = balanceChanges[i];
            }
        }
        emit SnapshotTaken(snapshotIndex, timestamp);
        snapshotIndex++;
    }

    /// @notice Render metadata from an array of balances
    /// @param balances Array of balances to render metadata from
    /// @return Concatenated string of encoded balances
    /// @dev Encodes each balance as a 5-byte string, except for the last balance which is encoded as a 2-byte string
    function renderMetadataFromBalances(uint256[] memory balances) public pure returns (string memory) {
        string memory concatenatedString = "";

        for (uint256 i = 0; i < balances.length; i++) {
            uint256 balance256 = balances[i];
            uint40 balance = uint40(balance256);
            bytes memory balanceByte = abi.encodePacked(balance);
            string memory balanceString = string(balanceByte);
            if (i == balances.length - 1) {
                balanceString = LibString.slice(balanceString, 0, 2);
            }
            concatenatedString = string.concat(concatenatedString, balanceString);
        }

        return concatenatedString;
    }

    /// @notice Render metadata based on live balances of stored addresses
    /// @return Concatenated string of encoded balances
    function renderLiveMetadata() public view returns (string memory) {
        uint256 addressCount = addresses.length;
        uint256[] memory balances = new uint256[](addressCount);
        for (uint256 i = 0; i < addressCount; i++) {
            balances[i] = address(addresses[i]).balance;
        }
        return renderMetadataFromBalances(balances);
    }

    /// @notice Render metadata from a specific snapshot
    /// @param snapshotIndex_ Index of the snapshot to render metadata from
    /// @return Concatenated string of encoded balance changes from the specified snapshot
    function renderSnapshotMetadata(uint256 snapshotIndex_) public view returns (string memory) {
        if (snapshotIndex_ >= snapshotIndex) revert SnapshotIndexOutOfBounds();
        if (snapshots[snapshotIndex_].snapshotTimestamp == 0) revert SnapshotNotTaken();

        uint256[] memory balances = getSnapshotBalances(snapshotIndex_);

        return renderMetadataFromBalances(balances);
    }

    /// @notice Set the index of the live snapshot
    /// @param _liveSnapshotIndex New index for the live snapshot
    /// @dev This function also sets showLiveData to false
    function setLiveSnapshotIndex(uint256 _liveSnapshotIndex) public onlyCollector {
        if (_liveSnapshotIndex >= snapshotIndex) revert SnapshotIndexOutOfBounds();
        if (snapshots[_liveSnapshotIndex].snapshotTimestamp == 0) revert SnapshotNotTaken();

        liveSnapshotIndex = _liveSnapshotIndex;
        showLiveData = false;
        emit LiveSnapshotIndexSet(_liveSnapshotIndex);
    }

    /// @notice Set the visibility of live data
    /// @param _showLiveData New visibility state for live data
    function setShowLiveData(bool _showLiveData) public onlyCollector {
        showLiveData = _showLiveData;
        emit ShowLiveDataSet(_showLiveData);
    }

    /// @notice Render metadata from the current live snapshot or live data
    /// @return Concatenated string of encoded balance changes from the live snapshot or live data
    function renderMetadata() public view returns (string memory) {
        if (showLiveData) {
            return renderLiveMetadata();
        } else {
            return renderSnapshotMetadata(liveSnapshotIndex);
        }
    }

    /// @notice Retrieve the balances from a specific snapshot
    /// @param snapshotIndex_ Index of the snapshot to retrieve balance changes from
    /// @return balances Array of balances from the specified snapshot
    function getSnapshotBalances(uint256 snapshotIndex_) public view returns (uint256[] memory balances) {
        if (snapshotIndex_ >= snapshotIndex) revert SnapshotIndexOutOfBounds();
        if (snapshots[snapshotIndex_].snapshotTimestamp == 0) revert SnapshotNotTaken();

        uint256 addressCount = addresses.length;
        balances = new uint256[](addressCount);
        for (uint256 i = 0; i < addressCount; i++) {
            if (snapshots[snapshotIndex_].balanceChanges[i] != 0) {
                balances[i] = initialBalances[i] + snapshots[snapshotIndex_].balanceChanges[i];
            } else {
                balances[i] = initialBalances[i];
            }
        }
    }

    /// @notice Get the deficit balance from the initial snapshot
    /// @return deficitBalance The total balance change since the initial snapshot
    function getDeficitBalanceFromTheInitialSnapshot() public view returns (uint256) {
        uint256 totalBalanceChange = 0;
        uint256 addressCount = addresses.length;
        for (uint256 i = 0; i < addressCount; i++) {
            address addr = addresses[i];
            totalBalanceChange += address(addr).balance - uint256(initialBalances[i]);
        }
        return totalBalanceChange;
    }
}
