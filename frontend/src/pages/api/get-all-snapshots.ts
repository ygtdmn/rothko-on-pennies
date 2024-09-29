import { createPublicClient, Hex, http } from "viem";
import { sepolia } from "viem/chains";
import { metadataRendererV2Abi } from "../../app/metadata-renderer-v2.abi";
import NodeCache from "node-cache";

const publicClient = createPublicClient({
  chain: sepolia,
  transport: http(process.env.RPC_URL as string),
});

// Contract configuration
const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS as Hex;

// Type definitions
interface Snapshot {
  id: number;
  date: string;
  svgData: string;
}

interface SnapshotData {
  live: string;
  snapshots: Snapshot[];
}

// Create a cache instance
const cache = new NodeCache({ stdTTL: 60 }); // 60 seconds TTL

/**
 * Fetches all snapshots from the smart contract
 * @returns {Promise<SnapshotData>} Object containing live metadata and an array of snapshots
 */
async function getAllSnapshots(): Promise<SnapshotData> {
  // Check if data is in cache
  const cachedData = cache.get("snapshotData") as SnapshotData | undefined;
  if (cachedData) {
    console.log("Returning cached snapshot data");
    return cachedData;
  }

  // Create public client for interacting with the blockchain

  // Add timeout for RPC requests
  const timeout = 60000; // 60 seconds

  // Helper function to handle timeouts
  const withTimeout = <T>(promise: Promise<T>, ms: number): Promise<T> => {
    return Promise.race([
      promise,
      new Promise<T>((_, reject) => setTimeout(() => reject(new Error("Request timed out")), ms)),
    ]);
  };

  try {
    // Fetch current snapshot index with timeout
    const currentSnapshotIndex = await withTimeout(
      publicClient.readContract({
        address: contractAddress,
        abi: metadataRendererV2Abi,
        functionName: "snapshotIndex",
      }) as Promise<bigint>,
      timeout,
    );
    console.log("Current snapshot index:", currentSnapshotIndex);

    // Fetch live metadata with timeout
    const liveMetadata = await withTimeout(
      publicClient.readContract({
        address: contractAddress,
        abi: metadataRendererV2Abi,
        functionName: "renderLiveMetadata",
      }) as Promise<string>,
      timeout,
    );

    // Prepare promises for fetching all snapshots
    const snapshotPromises = [];

    // Fetch all snapshots
    for (let i = 0; i < Number(currentSnapshotIndex); i++) {
      console.log("Fetching snapshot:", i);
      snapshotPromises.push(
        (async () => {
          // Fetch snapshot metadata
          const metadata = (await publicClient.readContract({
            address: contractAddress,
            abi: metadataRendererV2Abi,
            functionName: "renderSnapshotMetadata",
            args: [BigInt(i)],
          })) as string;

          // Fetch snapshot timestamp
          const timestamp = (await publicClient.readContract({
            address: contractAddress,
            abi: metadataRendererV2Abi,
            functionName: "snapshots",
            args: [BigInt(i)],
          })) as bigint;

          return {
            id: i,
            date: timestamp.toString(),
            svgData: metadata,
          };
        })(),
      );
    }

    let snapshots = await Promise.all(snapshotPromises);

    // Add custom information for known snapshots
    const customSnapshots = [
      { id: 0, date: "1726370267", name: "Original Artwork" },
      { id: 1, date: "1726612919", name: "Takens Theorem Vandalized Version" },
      { id: 2, date: "1726678547", name: "Bushi's Annihilated Version" },
    ];

    snapshots = snapshots.map((snapshot, index) => {
      if (index < customSnapshots.length) {
        return {
          ...snapshot,
          date: customSnapshots[index].date,
          name: customSnapshots[index].name,
        };
      }
      return snapshot;
    });

    const result = {
      live: liveMetadata,
      snapshots: snapshots,
    };

    // Store the result in cache
    cache.set("snapshotData", result);

    return result;
  } catch (error) {
    console.error("Error fetching data from RPC server:", error);
    throw new Error("RPC server is unresponsive or too slow");
  }
}

import { NextApiRequest, NextApiResponse } from "next";

/**
 * GET route handler for fetching all snapshots
 * @param {NextApiRequest} req - The incoming request object
 * @param {NextApiResponse} res - The response object
 * @returns {Promise<void>}
 */
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "GET") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  try {
    const snapshotData = await getAllSnapshots();
    res.status(200).json(snapshotData);
  } catch (error) {
    console.error("Error fetching snapshots:", error);
    if (error instanceof Error && error.message === "RPC server is unresponsive or too slow") {
      res.status(503).json({ error: "RPC server is currently unavailable. Please try again later." });
    } else {
      res.status(500).json({ error: "Failed to fetch snapshots" });
    }
  }
}
