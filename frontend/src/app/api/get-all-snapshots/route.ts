import { createPublicClient, Hex } from "viem";
import { mainnet } from "viem/chains";
import { metadataRendererV2Abi } from "../../metadata-renderer-v2.abi";
import { mainnetTransport } from "../../../lib/mainnet-transport";

// Every snapshot read is fetched fresh from the chain, then held for 60 seconds.
export const dynamic = "force-dynamic";

const publicClient = createPublicClient({
  chain: mainnet,
  transport: mainnetTransport,
  // Reads issued together go out as one Multicall3 call, which keeps the
  // Worker's outbound requests per invocation low.
  batch: { multicall: true },
});

// Contract configuration
const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS as Hex;

// Type definitions
interface Snapshot {
  id: number;
  name?: string;
  date: string;
  svgData: string;
}

interface SnapshotData {
  live: string;
  snapshots: Snapshot[];
}

const CACHE_TTL_SECONDS = 60;
// The Cache API needs a URL key; this one never leaves the Worker.
const CACHE_KEY = "https://rothko-on-pennies.cache/api/get-all-snapshots";

// Per-isolate copy of the last result (the Cache API is shared across isolates
// in a data center, but it is a no-op on workers.dev hostnames).
let memoryCache: { data: SnapshotData; expires: number } | null = null;

function edgeCache(): Cache | null {
  const store = (globalThis as { caches?: CacheStorage & { default?: Cache } }).caches;
  return store?.default ?? null;
}

async function readCache(): Promise<SnapshotData | null> {
  if (memoryCache && memoryCache.expires > Date.now()) return memoryCache.data;
  const cache = edgeCache();
  if (!cache) return null;
  try {
    const hit = await cache.match(CACHE_KEY);
    if (!hit) return null;
    const data = (await hit.json()) as SnapshotData;
    memoryCache = { data, expires: Date.now() + CACHE_TTL_SECONDS * 1000 };
    return data;
  } catch {
    return null;
  }
}

async function writeCache(data: SnapshotData): Promise<void> {
  memoryCache = { data, expires: Date.now() + CACHE_TTL_SECONDS * 1000 };
  const cache = edgeCache();
  if (!cache) return;
  try {
    await cache.put(
      CACHE_KEY,
      new Response(JSON.stringify(data), {
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": `public, max-age=${CACHE_TTL_SECONDS}`,
        },
      }),
    );
  } catch (error) {
    console.error("Failed to store snapshot data in the cache:", error);
  }
}

/**
 * Fetches all snapshots from the smart contract
 * @returns {Promise<SnapshotData>} Object containing live metadata and an array of snapshots
 */
async function getAllSnapshots(): Promise<SnapshotData> {
  const cachedData = await readCache();
  if (cachedData) {
    console.log("Returning cached snapshot data");
    return cachedData;
  }

  // Add timeout for RPC requests
  const timeout = 60000; // 60 seconds

  // Helper function to handle timeouts
  const withTimeout = <T>(promise: Promise<T>, ms: number): Promise<T> => {
    let timer: ReturnType<typeof setTimeout> | undefined;
    return Promise.race([
      promise,
      new Promise<T>((_, reject) => {
        timer = setTimeout(() => reject(new Error("Request timed out")), ms);
      }),
    ]).finally(() => clearTimeout(timer));
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
    const snapshotPromises: Promise<Snapshot>[] = [];

    // Fetch all snapshots
    for (let i = 0; i < Number(currentSnapshotIndex); i++) {
      console.log("Fetching snapshot:", i);
      snapshotPromises.push(
        (async () => {
          const [metadata, timestamp] = await Promise.all([
            // Fetch snapshot metadata
            publicClient.readContract({
              address: contractAddress,
              abi: metadataRendererV2Abi,
              functionName: "renderSnapshotMetadata",
              args: [BigInt(i)],
            }) as Promise<string>,
            // Fetch snapshot timestamp
            publicClient.readContract({
              address: contractAddress,
              abi: metadataRendererV2Abi,
              functionName: "snapshots",
              args: [BigInt(i)],
            }) as Promise<bigint>,
          ]);

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

    await writeCache(result);

    return result;
  } catch (error) {
    console.error("Error fetching data from RPC server:", error);
    throw new Error("RPC server is unresponsive or too slow");
  }
}

/**
 * GET route handler for fetching all snapshots
 */
export async function GET() {
  try {
    const snapshotData = await getAllSnapshots();
    return Response.json(snapshotData);
  } catch (error) {
    console.error("Error fetching snapshots:", error);
    if (error instanceof Error && error.message === "RPC server is unresponsive or too slow") {
      return Response.json({ error: "RPC server is currently unavailable. Please try again later." }, { status: 503 });
    }
    return Response.json({ error: "Failed to fetch snapshots" }, { status: 500 });
  }
}

function methodNotAllowed() {
  return Response.json({ error: "Method Not Allowed" }, { status: 405 });
}

export { methodNotAllowed as POST, methodNotAllowed as PUT, methodNotAllowed as PATCH, methodNotAllowed as DELETE };
