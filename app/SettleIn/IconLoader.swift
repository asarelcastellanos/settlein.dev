import AppKit

enum IconLoader {
    static func image(token: String) async -> NSImage? {
        guard token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else { return nil }
        let file = "\(token)-256.png"
        #if DEBUG
        if let base = UserDefaults.standard.string(forKey: "iconBase") {
            return NSImage(contentsOf: URL(fileURLWithPath: base).appendingPathComponent(file))
        }
        #endif
        let cached = cacheFolder.appendingPathComponent(file)
        if let data = try? Data(contentsOf: cached), let image = NSImage(data: data) { return image }
        guard let data = await fetch(file), let image = NSImage(data: data) else { return nil }
        try? FileManager.default.createDirectory(at: cacheFolder, withIntermediateDirectories: true)
        try? data.write(to: cached, options: .atomic)
        return image
    }

    private static var cacheFolder: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SettleIn/icons")
    }

    private static func fetch(_ file: String) async -> Data? {
        let session = URLSession(configuration: Network.configuration(timeout: 15), delegate: SameHostOnly(), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        guard let url = URL(string: "https://\(CatalogClient.host)/icons/\(file)"),
              let (data, response) = try? await session.data(from: url),
              let http = response as? HTTPURLResponse, http.statusCode == 200, http.url?.host() == CatalogClient.host
        else { return nil }
        return data
    }
}
