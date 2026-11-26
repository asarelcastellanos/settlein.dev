import { loadCatalogStats } from "./catalog.js";

const stats = loadCatalogStats();

export const entryKinds = {
  app: { label: "App update" },
  catalog: { label: "Catalog change" },
  notice: { label: "Notice" },
};

export const tabs = [
  { id: "all", label: "Everything" },
  { id: "app", label: "App updates" },
  { id: "catalog", label: "Catalog changes" },
  { id: "notice", label: "Notices" },
];

export const releaseEntries = [
  {
    kind: "app",
    date: "[RELEASE DATE]",
    iso: "",
    title: "SettleIn [VERSION]",
    lede: "The first release.",
    groups: [
      {
        heading: "Install",
        items: [
          "Pick apps on settlein.dev",
          "SettleIn opens and starts installing",
          "Every app installs in one go",
        ],
      },
      {
        heading: "Safety",
        items: [
          "Developer ID signature checked",
          "Apple notarization checked",
          "SHA-256 checksum checked where published",
        ],
      },
      {
        heading: "Uninstall",
        items: ["Remove any app SettleIn installed", "Its leftovers go with it"],
      },
      {
        heading: "Runs on",
        items: ["Apple silicon Macs", "macOS 26 and macOS 27"],
      },
    ],
  },
  {
    kind: "catalog",
    date: "[RELEASE DATE]",
    iso: "",
    title: "The launch catalog",
    lede: `${stats.total} apps in ${stats.categories.length} categories. Catalog changes reach SettleIn the next time it opens; no app update needed.`,
    groups: [
      {
        heading: "Categories",
        items: stats.categories.map(([name, count]) => `${name} · ${count}`),
      },
      {
        heading: "Install type",
        items: [`${stats.copied} copy straight to Applications`, `${stats.installer} open in Apple’s Installer`],
      },
      {
        heading: "Checksums",
        items: [`${stats.checksummed} have a published checksum`, `${stats.unchecked} rely on signature and notarization`],
      },
    ],
  },
];
