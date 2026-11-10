# Rothko on Pennies Frontend

This is the frontend application for the Rothko on Pennies project, a digital, fully on-chain artwork that encodes a
dithered and scaled-down derivative of Mark Rothko's "Composition (1959)" into the balances of hundreds of Ethereum
wallet addresses.

## Overview

The frontend provides an interactive interface for users to view the artwork, explore its history through snapshots, and
interact with the smart contract (for collector).

## Features

- Display of the live artwork
- Snapshot gallery showcasing the artwork's evolution
- Collector-specific actions (taking snapshots, setting live view)

## Tech Stack

- Next.js App Router, built with [vinext](https://github.com/cloudflare/vinext) (Vite) and served as a Cloudflare Worker
- React
- TypeScript
- Wagmi (for Ethereum interactions)
- RainbowKit (for wallet connection)
- Framer Motion (for animations)
- Tailwind CSS (for styling)

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```
   pnpm install
   ```
3. Environment variables: the public values (`NEXT_PUBLIC_CONTRACT_ADDRESS`, `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`) are
   committed in `.env.production` and end up in the bundle. For local development, put overrides in `.env.local`. The
   app needs no secrets.
4. Run the development server:
   ```
   pnpm dev
   ```
5. Open [http://localhost:3000](http://localhost:3000) in your browser

## Commands

```
pnpm dev        # vinext dev server on port 3000
pnpm build      # build the Worker (output in .cloudflare/output)
pnpm start      # run the built Worker locally in workerd (vite preview)
pnpm lint       # ESLint
pnpm typecheck  # Worker runtime types + tsc
pnpm run deploy # build and deploy to Cloudflare (needs `npx cf auth login`)
```

## Deployment

The site runs on Cloudflare Workers as the Worker `rothko-on-pennies`, at https://rop.yigitduman.com.
`cloudflare.config.ts` declares it: custom domain rop.yigitduman.com, workers.dev off, preview URLs off. A deploy applies
these fields, so a toggle flipped in the dashboard comes back on the next deploy unless the config agrees.

Workers Builds deploys every push to master: root directory `frontend`, no build command, deploy command
`pnpm run deploy`, preview builds off, `NODE_VERSION` 24. `pnpm run deploy` also works by hand.

`/api/get-all-snapshots` reads the live view and every snapshot from the `ROPMetadataRendererV2` contract through a
fallback list of public RPCs (`src/lib/mainnet-transport.ts`, batched into Multicall3) and caches the result for 60
seconds: in the isolate's memory and in the Workers Cache API.

## Project Structure

- `src/app/page.tsx`: Main component containing the Rothko Gallery
- `src/app/api/get-all-snapshots/route.ts`: API route for fetching snapshots
- `src/app/metadata-renderer-v2.abi.ts`: ABI for the smart contract
- `cloudflare.config.ts`, `vite.config.ts`: Worker and vinext configuration

## License

This project is licensed under the MIT License.

## Disclaimer

This README.md file was generated with the assistance of an AI language model. While efforts have been made to ensure
accuracy and completeness, please review and verify the information before use. If you notice any inconsistencies or
have suggestions for improvement, please feel free to contribute or raise an issue.
