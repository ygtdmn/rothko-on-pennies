import { fallback, http } from "viem";

export const mainnetTransport = fallback([
  http("https://ethereum-rpc.publicnode.com"),
  http("https://1rpc.io/eth"),
  http("https://rpc.mevblocker.io"),
  http("https://rpc.flashbots.net"),
  http("https://eth.meowrpc.com"),
  http("https://eth.drpc.org"),
  http("https://eth.merkle.io"),
  http("https://endpoints.omniatech.io/v1/eth/mainnet/public"),
  http("https://0xrpc.io/eth"),
  http("https://rpc.payload.de"),
  http("https://rpc.public.curie.radiumblock.co/http/ethereum"),
  http("https://eth.blockrazor.xyz"),
]);
