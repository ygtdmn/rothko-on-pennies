# Rothko on Pennies Frontend

This is the frontend application for the Rothko on Pennies project, a digital, fully on-chain artwork that encodes a dithered and scaled-down derivative of Mark Rothko's "Composition (1959)" into the balances of hundreds of Ethereum wallet addresses.

## Overview

The frontend provides an interactive interface for users to view the artwork, explore its history through snapshots, and interact with the smart contract (for collector).

## Features

- Display of the live artwork
- Snapshot gallery showcasing the artwork's evolution
- Collector-specific actions (taking snapshots, setting live view)

## Tech Stack

- Next.js
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
   npm install
   ```
3. Set up environment variables:
   - Create a `.env.local` file in the root of the frontend folder
   - Add the following variables:
     ```
     NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
     NEXT_PUBLIC_CONTRACT_ADDRESS=your_contract_address
     ```
4. Run the development server:
   ```
   npm run dev
   ```
5. Open [http://localhost:3000](http://localhost:3000) in your browser

## Project Structure

- `src/app/page.tsx`: Main component containing the Rothko Gallery
- `src/pages/api/get-all-snapshots.ts`: API route for fetching snapshots
- `src/app/metadata-renderer-v2.abi.ts`: ABI for the smart contract
- `public/`: Static assets

## License

This project is licensed under the MIT License.


## Disclaimer

This README.md file was generated with the assistance of an AI language model. While efforts have been made to ensure accuracy and completeness, please review and verify the information before use. If you notice any inconsistencies or have suggestions for improvement, please feel free to contribute or raise an issue.

