import { fallback, http } from "viem";

// Free public RPCs, scored 2026-11-10 (CORS, eth_call, JSON-RPC batch,
// eth_getLogs over 1k/10k/50k/full ranges). The first three answer a full-history getLogs in
// one call; most others refuse wide log ranges. No per-endpoint retries: a refusal moves
// straight to the next endpoint instead of backing off on one that will not answer.
const RPC_OPTIONS = { retryCount: 0, timeout: 10_000 } as const;

export const mainnetTransport = fallback(
  [
    http("https://gateway.tenderly.co/public/mainnet", RPC_OPTIONS),
    http("https://mainnet.gateway.tenderly.co", RPC_OPTIONS),
    http("https://ethereum-json-rpc.stakely.io", RPC_OPTIONS),
    http("https://rpc.mevblocker.io/fast", RPC_OPTIONS),
    http("https://eth.api.pocket.network", RPC_OPTIONS),
    http("https://ethereum-rpc.publicnode.com", RPC_OPTIONS),
    http("https://eth.drpc.org", RPC_OPTIONS),
    http("https://1.rpc.thirdweb.com", RPC_OPTIONS),
    http("https://eth.blockrazor.xyz", RPC_OPTIONS),
    http("https://0xrpc.io/eth", RPC_OPTIONS),
  ],
  { retryCount: 1 },
);
