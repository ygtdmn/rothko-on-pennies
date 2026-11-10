import { defineConfig, defineWorker } from "cf/config";

export default defineConfig({
  worker: defineWorker({
    name: "rothko-on-pennies",
    // workers.dev only: no custom domain is attached by a deploy.
    domains: [],
    // Deploys enforce these, so a toggle flipped in the dashboard comes back
    // on the next push unless it is set here.
    workersDev: true,
    previewUrls: false,
    entrypoint: "vinext/server/fetch-handler",
    compatibilityDate: "2026-11-08",
    compatibilityFlags: ["nodejs_compat"],
    assets: {
      htmlHandling: "none",
      notFoundHandling: "none",
      runWorkerFirst: ["/*", "!/_next/static/*", "!/*/_next/static/*"],
    },
    observability: { enabled: true },
  }),
});
