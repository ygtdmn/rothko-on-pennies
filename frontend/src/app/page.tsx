"use client";

import { useAccount, WagmiProvider, useReadContract, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import "@rainbow-me/rainbowkit/styles.css";
import React, { useEffect, useState, useCallback } from "react";
import { ConnectButton, darkTheme, getDefaultConfig, RainbowKitProvider, Theme } from "@rainbow-me/rainbowkit";
import { mainnet, sepolia } from "wagmi/chains";
import { motion } from "framer-motion";
import { ChevronLeft, ChevronRight } from "lucide-react";
import merge from "lodash.merge";
import { Montserrat } from "next/font/google";
import Image from "next/image";
import { Hex, http } from "viem";
import ropSvg from "../app/images/rop.svg";
import { metadataRendererV2Abi } from "./metadata-renderer-v2.abi";
const montserrat = Montserrat({ subsets: ["latin"] });

const queryClient = new QueryClient();

const customDarkTheme = merge(darkTheme(), {
  colors: {
    connectButtonBackground: "#2f2f2f",
    accentColor: "rgb(153 27 27)",
  },
} as Theme);

const config = getDefaultConfig({
  appName: "Rothko on Pennies",
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID as string,
  chains: [sepolia],
  transports: {
    [sepolia.id]: http(process.env.NEXT_PUBLIC_RPC_URL as string),
  },
  ssr: false,
});

// Add the contract ABI and address
const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS as Hex;
const contractConfig = {
  abi: metadataRendererV2Abi,
  address: contractAddress,
};

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

const RothkoGallery = () => {
  const [snapshots, setSnapshots] = useState<Snapshot[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedSnapshot, setSelectedSnapshot] = useState<Snapshot | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const snapshotsPerPage = 3;
  const { isConnected, address } = useAccount();
  const [mounted, setMounted] = useState(false);
  const [snapshotData, setSnapshotData] = useState<SnapshotData | null>(null);
  const [error, setError] = useState<string | null>(null);

  const { data: isCollector } = useReadContract({
    ...contractConfig,
    functionName: "isCollector",
    args: [address as Hex],
    query: {
      enabled: isConnected,
    },
  });

  const {
    data: showLiveData,
    error: showLiveDataError,
    isPending: showLiveDataIsPending,
    refetch: showLiveDataRefetch,
  } = useReadContract({
    ...contractConfig,
    functionName: "showLiveData",
  });

  const { data: liveSnapshotIndex, refetch: liveSnapshotIndexRefetch } = useReadContract({
    ...contractConfig,
    functionName: "liveSnapshotIndex",
  });

  const {
    data: hash,
    error: writeContractError,
    isPending: writeContractIsPending,
    writeContract,
  } = useWriteContract();

  const takeSnapshot = async () => {
    writeContract({
      ...contractConfig,
      functionName: "takeSnapshot",
    });
  };

  const setToLiveView = async () => {
    writeContract({
      ...contractConfig,
      functionName: "setShowLiveData",
      args: [true],
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  useEffect(() => {
    if (writeContractError) {
      console.log("Write Contract Error:", writeContractError);
    }
  }, [writeContractError]);

  const fetchSnapshots = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch("/api/get-all-snapshots");
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to fetch snapshots");
      }
      const data: SnapshotData = await response.json();
      setSnapshotData(data);
      const processedSnapshots = data.snapshots.map((snapshot) => ({
        ...snapshot,
        name: getSnapshotName(snapshot),
      }));
      setSnapshots(processedSnapshots);
    } catch (error) {
      console.error("Error fetching snapshots:", error);
      setError(error instanceof Error ? error.message : "An unknown error occurred");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isConfirmed) {
      fetchSnapshots();
      showLiveDataRefetch();
      liveSnapshotIndexRefetch();
    }
  }, [isConfirmed, fetchSnapshots, showLiveDataRefetch, liveSnapshotIndexRefetch]);

  useEffect(() => {
    fetchSnapshots();
  }, [fetchSnapshots]);

  useEffect(() => {
    setMounted(true);
  }, []);

  const getSnapshotName = (snapshot: Snapshot) => {
    if (snapshot.name) return snapshot.name;
    return `Snapshot ${snapshot.id + 1}`;
  };

  const SnapshotCard = ({ snapshot, onClick }: { snapshot: Snapshot; onClick: (snapshot: Snapshot) => void }) => (
    <motion.div
      className="cursor-pointer w-full overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300"
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      onClick={() => onClick(snapshot)}
    >
      <div className="relative w-full" style={{ paddingBottom: "132.94%" }}>
        <Image src={`${snapshot.svgData}`} alt={snapshot.name || "Snapshot"} fill className="object-cover" />
      </div>
      <div className="p-2 bg-neutral-900">
        <span className="text-white text-sm font-semibold">{snapshot.name}</span>
      </div>
    </motion.div>
  );

  const paginate = (pageNumber: number) => setCurrentPage(pageNumber);

  const indexOfLastSnapshot = currentPage * snapshotsPerPage;
  const indexOfFirstSnapshot = indexOfLastSnapshot - snapshotsPerPage;
  const currentSnapshots = snapshots.slice(indexOfFirstSnapshot, indexOfLastSnapshot);

  if (!mounted) {
    return (
      <div className="flex justify-center items-center h-screen bg-stone-950">
        <div className="w-16 h-16 border-4 border-red-800 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen bg-stone-950 text-gray-200 ${montserrat.className}`}>
      <header className="bg-gradient-to-b from-red-800 via-orange-900 to-red-950 py-20">
        <div className="max-w-6xl mx-auto px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
            <div>
              <h1 className="text-5xl sm:text-6xl font-extrabold mb-2 text-white">ROTHKO ON PENNIES</h1>
              <h2 className="text-lg sm:text-xl font-semibold mb-4 text-gray-200">by Yigit Duman</h2>
              <p className="text-xl sm:text-2xl text-gray-200 mb-8">
                A dithered and scaled down version of Mark Rothko&apos;s &quot;Composition (1959)&quot; encoded on-chain
                in balances of 981 Ethereum wallets.
              </p>
              <div className="flex space-x-4">
                <button
                  onClick={() => {
                    const overviewSection = document.getElementById("overview");
                    if (overviewSection) {
                      overviewSection.scrollIntoView({ behavior: "smooth", block: "start" });
                    }
                  }}
                  className="bg-transparent border border-white text-white px-6 py-3 rounded-lg hover:bg-white hover:text-red-900 transition-colors"
                >
                  Learn More
                </button>
              </div>
            </div>
            <div className="hidden md:block">
              {snapshotData && snapshotData.live ? (
                <>
                  <div className="relative w-full" style={{ paddingBottom: "132.94%" }}>
                    <Image
                      src={`${snapshotData.live}`}
                      alt="Live Rothko-inspired artwork"
                      fill
                      className="object-cover shadow-2xl"
                    />
                  </div>
                  <p className="text-center mt-2 text-white text-sm italic">Live version of the Artwork</p>
                </>
              ) : (
                <>
                  <div className="relative w-full" style={{ paddingBottom: "132.94%" }}>
                    <Image
                      src={ropSvg}
                      priority
                      alt="Initial Rothko-inspired artwork"
                      fill
                      className="object-cover shadow-2xl"
                    />
                  </div>
                  <p className="text-center mt-2 text-white text-sm">Rothko on Pennies</p>
                </>
              )}
            </div>
          </div>
        </div>
      </header>

      <nav className="bg-black py-4 px-8 sticky top-0 z-10 border-b border-gray-900">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="flex space-x-6">
            <a href="#overview" className="text-gray-400 hover:text-white">
              Overview
            </a>
            <a href="#gallery" className="text-gray-400 hover:text-white">
              Snapshot Gallery
            </a>
          </div>
          <div className="flex items-center space-x-4">
            <ConnectButton label="Collector Mode" />
          </div>
        </div>
      </nav>

      <main id="overview" className="max-w-6xl mx-auto px-8 py-20">
        <section className="mb-24">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="bg-red-800 p-12 rounded-lg flex flex-col h-full">
              <div>
                <h2 className="text-4xl font-bold mb-6 text-white">Project Overview</h2>
                <p className="text-gray-200 mb-6 leading-relaxed">
                  &quot;Rothko on Pennies&quot; is a digital recreation of Mark Rothko&apos;s &quot;Composition
                  (1959)&quot; painting, stored entirely on the Ethereum blockchain. The artwork is broken down into
                  tiny pieces, each represented by a small amount of ETH spread across 981 wallets. When put together,
                  these pieces form a simplified version of Rothko&apos;s original work. The project uses custom smart
                  contracts to create and display the artwork using only the information stored in these wallet
                  balances.
                </p>
                <div className="mt-8">
                  <h3 className="text-2xl font-semibold mb-4 text-white">Key Features</h3>
                  <ul className="list-disc list-inside text-gray-200 space-y-2">
                    <li>On-chain storage using multiple Ethereum wallets</li>
                    <li>Custom smart contracts for artwork rendering</li>
                    <li>Interactive snapshot gallery</li>
                    <li>Interactive artwork that can be altered by anyone</li>
                  </ul>
                </div>
                <div className="mt-8">
                  <a
                    href="https://x.com/YigitDuman/status/1835290645423866215"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="bg-white text-neutral-800 px-6 py-3 rounded hover:bg-gray-200 transition-colors inline-block"
                  >
                    Read More on Twitter/X
                  </a>
                </div>
              </div>
            </div>
            <div className="bg-orange-700 p-12 rounded-lg flex flex-col justify-between h-full">
              <h3 className="text-3xl font-bold mb-6 text-white">Project Timeline</h3>
              <div className="relative pl-8 border-l-2 border-white">
                {[
                  {
                    date: "Sept 16, 2024",
                    title: "Mint and Genesis Sale",
                    description: "After a 24 hours long auction, the artwork was sold for 1.256 ETH to ",
                    username: "serc1n",
                  },
                  {
                    date: "Sept 17, 2024",
                    title: "First On-Chain Vandalism",
                    description: "Less than 24 hours after the sale, the artwork was vandalized by ",
                    username: "takenstheorem",
                    additionalText: ", adding a dent to the artwork",
                  },
                  {
                    date: "Sept 18, 2024",
                    title: "Complete Destruction",
                    description: "Less than 12 hours later, ",
                    username: "thecryptobushi",
                    additionalText: " destroyed the artwork completely, rendering it invisible",
                  },
                  {
                    date: "Sept 22, 2024",
                    title: "Restoration",
                    description: "",
                    username: "takenstheorem",
                    additionalText:
                      " brought the artwork back to its original form while incorporating their unique alteration",
                  },
                ].map((event, index) => (
                  <div key={index} className="mb-6 relative">
                    <div className="absolute -left-10 mt-1.5 w-4 h-4 rounded-full bg-white"></div>
                    <p className="text-sm text-gray-300 mb-1">{event.date}</p>
                    <h4 className="text-xl font-semibold text-white mb-1">{event.title}</h4>
                    <p className="text-gray-200">
                      {event.description}
                      <a
                        href={`https://x.com/${event.username}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-white hover:underline"
                      >
                        @{event.username}
                      </a>
                      {event.additionalText}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section id="gallery" className="mb-24">
          <h2 className="text-4xl font-bold mb-6 text-white">Snapshot Gallery</h2>
          <p className="text-gray-200 mb-4">
            The Snapshot Gallery is a visual history of &quot;Rothko on Pennies&quot;. Each snapshot represents a unique
            moment in the artwork&apos;s lifecycle, showcasing how it has evolved over time.
          </p>
          <p className="text-gray-200 mb-4">
            {showLiveData && isCollector && <span>Token currently showcasing live view</span>}
            {!showLiveData && isCollector && liveSnapshotIndex !== undefined && (
              <span className="text-blue-400">
                Token currently showcasing{" "}
                {snapshots.find((s) => s.id === Number(liveSnapshotIndex))?.name ||
                  `Snapshot ${Number(liveSnapshotIndex) + 1}`}
              </span>
            )}
          </p>
          <div>
            {isCollector ? (
              <div>
                <div className="flex space-x-4 mb-6">
                  <button
                    onClick={() => {
                      takeSnapshot();
                    }}
                    className="bg-red-800 text-white px-4 py-2 rounded-md hover:bg-red-700 transition-colors"
                  >
                    Take A Snapshot
                  </button>

                  {!showLiveData && !showLiveDataIsPending && !showLiveDataError && (
                    <button
                      onClick={() => {
                        setToLiveView();
                      }}
                      className="bg-gray-700 text-white px-4 py-2 rounded-md hover:bg-gray-600 transition-colors"
                    >
                      Set To Live View
                    </button>
                  )}
                </div>
              </div>
            ) : (
              isConnected && (
                <div className="mb-6">
                  <p className="text-yellow-400 font-semibold p-3 rounded-md border border-yellow-500">
                    ⚠️ Warning: Connected wallet is not the collector.
                  </p>
                </div>
              )
            )}
          </div>

          {writeContractError && (
            <div className="bg-red-800 text-white p-4 rounded-md mb-6">
              <p className="font-bold">Error:</p>
              <p>
                {writeContractError.message.split("Details:")[1]?.split("Request:")[0]?.trim() ||
                  writeContractError.message}
              </p>
            </div>
          )}

          {(writeContractIsPending || isConfirming) && (
            <div className="bg-yellow-400 text-black p-4 rounded-md mb-6 flex items-center">
              <div className="w-6 h-6 border-2 border-black border-t-transparent rounded-full animate-spin mr-3"></div>
              <div>
                <p className="font-bold">Pending:</p>
                <p>Transaction is processing...</p>
              </div>
            </div>
          )}

          {isConfirmed && (
            <div className="bg-green-800 text-white p-4 rounded-md mb-6">
              <p className="font-bold">Success:</p>
              <p>Transaction is confirmed!</p>
            </div>
          )}

          {error && (
            <div className="bg-red-800 text-white p-4 rounded-md mb-6">
              <p className="font-bold">Error:</p>
              <p>{error}</p>
              <button
                onClick={fetchSnapshots}
                className="mt-2 px-4 py-2 bg-white text-red-800 rounded-md hover:bg-gray-200 transition-colors"
              >
                Retry
              </button>
            </div>
          )}

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
            {loading ? (
              // Loading spinner
              <div className="col-span-full flex justify-start items-center">
                <div className="w-12 h-12 border-4 border-red-800 border-t-transparent rounded-full animate-spin"></div>
              </div>
            ) : error ? (
              // Error message (in addition to the error box above)
              <div className="col-span-full text-center text-gray-400">
                Unable to load snapshots. Please try again later.
              </div>
            ) : snapshots.length === 0 ? (
              // No snapshots message
              <div className="col-span-full text-center text-gray-400">No snapshots available at the moment.</div>
            ) : (
              // Snapshot cards
              currentSnapshots.map((snapshot) => (
                <SnapshotCard key={snapshot.id} snapshot={snapshot} onClick={setSelectedSnapshot} />
              ))
            )}
          </div>
          {!loading && snapshots.length > snapshotsPerPage && (
            <div className="mt-6 flex justify-center items-center space-x-2">
              <button
                onClick={() => paginate(currentPage - 1)}
                disabled={currentPage === 1}
                className="p-2 rounded-full bg-gray-200 dark:bg-gray-700 disabled:opacity-50"
              >
                <ChevronLeft className="h-5 w-5" />
              </button>
              <span>
                Page {currentPage} of {Math.ceil(snapshots.length / snapshotsPerPage)}
              </span>
              <button
                onClick={() => paginate(currentPage + 1)}
                disabled={currentPage === Math.ceil(snapshots.length / snapshotsPerPage)}
                className="p-2 rounded-full bg-gray-200 dark:bg-gray-700 disabled:opacity-50"
              >
                <ChevronRight className="h-5 w-5" />
              </button>
            </div>
          )}
        </section>
      </main>

      <footer className="bg-black py-8 px-8 mt-6 border-t border-gray-900">
        <div className="max-w-6xl mx-auto text-center text-gray-400">
          <p>
            Created by Yigit Duman |
            <a
              href="https://twitter.com/yigitduman"
              target="_blank"
              rel="noopener noreferrer"
              className="text-red-900 hover:text-red-800 mx-2"
            >
              Twitter / X
            </a>
            |
            <a
              href="https://github.com/ygtdmn/rothko-on-pennies"
              target="_blank"
              rel="noopener noreferrer"
              className="text-red-900 hover:text-red-800 ml-2"
            >
              View on GitHub
            </a>
          </p>
        </div>
      </footer>

      {selectedSnapshot && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 bg-black bg-opacity-50 dark:bg-opacity-70 flex items-center justify-center p-4"
          onClick={() => setSelectedSnapshot(null)}
        >
          <motion.div
            className="bg-white dark:bg-gray-800 rounded-lg p-4 max-w-sm w-full"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-xl font-bold mb-3">{selectedSnapshot.name}</h2>
            <div className="relative w-full" style={{ paddingBottom: "132.94%" }}>
              <Image
                src={`${selectedSnapshot.svgData}`}
                alt={selectedSnapshot.name || "Snapshot"}
                fill
                className="object-cover"
              />
            </div>
            <p className="text-gray-600 dark:text-gray-400 text-sm mt-3 mb-3">
              Date: {new Date(parseInt(selectedSnapshot.date) * 1000).toUTCString()}
            </p>
            {isCollector &&
              !(
                showLiveData === false &&
                liveSnapshotIndex !== undefined &&
                BigInt(liveSnapshotIndex) === BigInt(selectedSnapshot.id)
              ) && (
                <button
                  onClick={() => {
                    writeContract({
                      ...contractConfig,
                      functionName: "setLiveSnapshotIndex",
                      args: [BigInt(selectedSnapshot.id)],
                    });
                  }}
                  className="w-full bg-red-900 hover:bg-red-800 text-white font-bold py-2 px-4 rounded transition duration-300"
                  disabled={!isCollector || writeContractIsPending || isConfirming}
                >
                  {writeContractIsPending || isConfirming ? "Processing..." : "Set Live Snapshot"}
                </button>
              )}
          </motion.div>
        </motion.div>
      )}
    </div>
  );
};

const App = () => {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider theme={customDarkTheme}>
          <RothkoGallery />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
};

export default App;
