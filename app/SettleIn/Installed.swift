import Foundation

enum Installed {
    static func isInstalled(_ app: CatalogApp, in folders: [URL] = defaultFolders) -> Bool {
        app.appBundles.allSatisfy { bundle in
            folders.contains { FileManager.default.fileExists(atPath: $0.appending(path: bundle).path) }
        }
    }

    static var defaultFolders: [URL] {
        [
            URL(filePath: "/Applications", directoryHint: .isDirectory),
            URL.homeDirectory.appending(path: "Applications", directoryHint: .isDirectory),
        ]
    }
}
