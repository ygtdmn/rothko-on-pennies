import type { Metadata } from "next";
import "@fontsource-variable/montserrat/wght.css";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rothko on Pennies by Yigit Duman",
  description:
    "Rothko on Pennies is a digital, fully on-chain artwork that encodes a dithered and scaled down derivative of Mark Rothko's 'Composition (1959)' into the balances of hundreds of Ethereum wallet addresses.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
