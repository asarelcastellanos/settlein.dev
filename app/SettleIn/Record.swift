import Foundation

struct InstallEntry: Codable, Equatable {
    let token: String
    let installerType: String
    let date: Date
}

enum RecordRead: Equatable {
    case entries([InstallEntry])
    case unreadable
}

enum InstallRecord {
    static var file: URL {
        #if DEBUG
        if let path = UserDefaults.standard.string(forKey: "recordFile") {
            return URL(fileURLWithPath: path)
        }
        #endif
        return URL.applicationSupportDirectory
            .appending(path: "SettleIn", directoryHint: .isDirectory)
            .appending(path: "installs.json")
    }

    static var folder: URL { file.deletingLastPathComponent() }

    static func read() -> RecordRead {
        guard FileManager.default.fileExists(atPath: file.path) else { return .entries([]) }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return .entries(try decoder.decode([InstallEntry].self, from: try Data(contentsOf: file)))
        } catch {
            let damaged = folder.appending(path: "installs.damaged.json")
            try? FileManager.default.removeItem(at: damaged)
            try? FileManager.default.moveItem(at: file, to: damaged)
            return .unreadable
        }
    }

    static func add(_ apps: [CatalogApp], on date: Date = Date()) {
        guard !apps.isEmpty else { return }
        var entries: [InstallEntry] = []
        if case .entries(let existing) = read() { entries = existing }
        for app in apps where !entries.contains(where: { $0.token == app.token }) {
            entries.append(InstallEntry(token: app.token, installerType: app.installerType.rawValue, date: date))
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? encoder.encode(entries).write(to: file, options: .atomic)
    }
}
