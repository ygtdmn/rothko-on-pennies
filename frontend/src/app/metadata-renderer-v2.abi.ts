export const metadataRendererV2Abi = [
  {
    type: "constructor",
    inputs: [
      { name: "_rothkoOnPennies", type: "address", internalType: "address" },
      { name: "partialAddresses", type: "address[]", internalType: "address[]" },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "addresses",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "createCustomSnapshot",
    inputs: [
      { name: "timestamp", type: "uint256", internalType: "uint256" },
      { name: "balanceChanges", type: "uint256[]", internalType: "uint256[]" },
      { name: "balanceChangeIndexes", type: "uint256[]", internalType: "uint256[]" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "deleteSnapshot",
    inputs: [{ name: "snapshotIndex_", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getDeficitBalanceFromTheInitialSnapshot",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getSnapshotBalances",
    inputs: [{ name: "snapshotIndex_", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "balances", type: "uint256[]", internalType: "uint256[]" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "initialBalances",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "", type: "uint40", internalType: "uint40" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "initializeBalances",
    inputs: [{ name: "_initialBalances", type: "uint40[981]", internalType: "uint40[981]" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "initializeRemainingAddresses",
    inputs: [
      { name: "_addresses", type: "address[]", internalType: "address[]" },
      { name: "startIndex", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "isCollector",
    inputs: [{ name: "addr", type: "address", internalType: "address" }],
    outputs: [{ name: "", type: "bool", internalType: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "isCollector",
    inputs: [],
    outputs: [{ name: "", type: "bool", internalType: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "liveSnapshotIndex",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "renderInitialMetadata",
    inputs: [],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "renderLiveMetadata",
    inputs: [],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "renderMetadata",
    inputs: [],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "renderMetadataFromBalances",
    inputs: [{ name: "balances", type: "uint256[]", internalType: "uint256[]" }],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "pure",
  },
  {
    type: "function",
    name: "renderSnapshotMetadata",
    inputs: [{ name: "snapshotIndex_", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "", type: "string", internalType: "string" }],
    stateMutability: "view",
  },
  { type: "function", name: "renounceOwnership", inputs: [], outputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "rothkoOnPennies",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "contract IERC1155" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "setAddresses",
    inputs: [{ name: "_addresses", type: "address[981]", internalType: "address[981]" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setInitialBalances",
    inputs: [{ name: "_initialBalances", type: "uint40[981]", internalType: "uint40[981]" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setLiveSnapshotIndex",
    inputs: [{ name: "_liveSnapshotIndex", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setShowLiveData",
    inputs: [{ name: "_showLiveData", type: "bool", internalType: "bool" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "showLiveData",
    inputs: [],
    outputs: [{ name: "", type: "bool", internalType: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "snapshotIndex",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "snapshots",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "snapshotTimestamp", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  { type: "function", name: "takeSnapshot", inputs: [], outputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "transferOwnership",
    inputs: [{ name: "newOwner", type: "address", internalType: "address" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "event",
    name: "LiveSnapshotIndexSet",
    inputs: [{ name: "liveSnapshotIndex", type: "uint256", indexed: false, internalType: "uint256" }],
    anonymous: false,
  },
  {
    type: "event",
    name: "OwnershipTransferred",
    inputs: [
      { name: "previousOwner", type: "address", indexed: true, internalType: "address" },
      { name: "newOwner", type: "address", indexed: true, internalType: "address" },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "ShowLiveDataSet",
    inputs: [{ name: "showLiveData", type: "bool", indexed: false, internalType: "bool" }],
    anonymous: false,
  },
  {
    type: "event",
    name: "SnapshotDeleted",
    inputs: [{ name: "snapshotIndex", type: "uint256", indexed: false, internalType: "uint256" }],
    anonymous: false,
  },
  {
    type: "event",
    name: "SnapshotTaken",
    inputs: [
      { name: "snapshotIndex", type: "uint256", indexed: false, internalType: "uint256" },
      { name: "timestamp", type: "uint256", indexed: false, internalType: "uint256" },
    ],
    anonymous: false,
  },
  { type: "error", name: "CannotDeleteInitialSnapshots", inputs: [] },
  { type: "error", name: "InvalidAddressArrayLength", inputs: [] },
  { type: "error", name: "InvalidInitialBalancesArrayLength", inputs: [] },
  { type: "error", name: "MismatchedArrayLengths", inputs: [] },
  { type: "error", name: "NotCollector", inputs: [] },
  { type: "error", name: "SnapshotIndexOutOfBounds", inputs: [] },
  { type: "error", name: "SnapshotNotTaken", inputs: [] },
] as const;
