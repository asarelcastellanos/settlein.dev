export const entryKinds = {
  app: { label: "App update", filter: "app" },
  catalog: { label: "Catalog change", filter: "catalog" },
  notice: { label: "Notice", filter: "notice" },
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
    lede: "44 apps in 9 categories. Catalog changes reach SettleIn the next time it opens; no app update needed.",
    groups: [
      {
        heading: "Categories",
        items: [
          "Browsers · 3",
          "Communication · 5",
          "Developer tools · 9",
          "Media · 6",
          "Creative · 4",
          "Productivity and storage · 4",
          "Games · 2",
          "Security · 2",
          "Utilities · 9",
        ],
      },
      {
        heading: "Install type",
        items: ["38 copy straight to Applications", "6 open in Apple’s Installer"],
      },
      {
        heading: "Checksums",
        items: ["40 have a published checksum", "4 rely on signature and notarization"],
      },
    ],
  },
];
