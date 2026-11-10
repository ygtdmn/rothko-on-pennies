/** @type {import('next').NextConfig} */
const nextConfig = {
  // The page only renders data: URIs (on-chain SVGs) and one local SVG, so there is nothing to resize.
  images: { unoptimized: true },
};

export default nextConfig;
