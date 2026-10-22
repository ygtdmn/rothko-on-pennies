/** @type {import('next').NextConfig} */
const nextConfig = {
  // RainbowKit -> wagmi baseAccount connector -> @base-org/account (Node entry) -> @coinbase/cdp-sdk,
  // whose x402 helpers import the optional, uninstalled @x402/* peers. Turbopack fails the SSR
  // bundle on those; loading cdp-sdk from node_modules at runtime instead keeps them lazy.
  serverExternalPackages: ["@coinbase/cdp-sdk"],
};

export default nextConfig;
