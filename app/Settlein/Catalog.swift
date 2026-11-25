import Foundation

enum InstallerType: String {
    case app
    case pkg
}

struct CatalogApp: Identifiable, Equatable {
    let name: String
    let category: String
    let downloadURL: URL
    let version: String
    let installerType: InstallerType
    let appBundles: [String]
    let sha256: String?

    var id: String { name }
}

struct CatalogError: Error, Equatable {
    let reason: String
}

enum CatalogParser {
    static let maxBytes = 2_000_000

    private static let appKeys: Set<String> = [
        "name", "category", "downloadUrl", "version", "installerType",
        "appBundles", "leftoverPaths", "pkgutilIds", "sha256",
    ]
    private static let leftoverKeys: Set<String> = ["path", "from"]
    private static let leftoverActions: Set<String> = ["delete", "trash", "rmdir"]
    private static let pkgutilKeys: Set<String> = ["id", "pattern"]

    static func parse(_ data: Data) throws -> [CatalogApp] {
        guard data.count <= maxBytes else { throw CatalogError(reason: "catalog is larger than \(maxBytes) bytes") }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CatalogError(reason: "catalog is not a JSON object")
        }
        guard Set(root.keys) == ["apps"] else { throw CatalogError(reason: "catalog has keys other than apps") }
        guard let list = root["apps"] as? [Any], !list.isEmpty else {
            throw CatalogError(reason: "apps is not a non-empty list")
        }
        var seen = Set<String>()
        var apps: [CatalogApp] = []
        for (index, item) in list.enumerated() {
            let app = try parseApp(item, index: index)
            guard seen.insert(app.name).inserted else { throw CatalogError(reason: "duplicate app \(app.name)") }
            apps.append(app)
        }
        return apps
    }

    private static func parseApp(_ item: Any, index: Int) throws -> CatalogApp {
        let at = "app \(index)"
        guard let dict = item as? [String: Any] else { throw CatalogError(reason: "\(at) is not an object") }
        guard Set(dict.keys) == appKeys else { throw CatalogError(reason: "\(at) has a missing or unknown key") }
        let name = try text(dict["name"], "\(at) name")
        let category = try text(dict["category"], "\(at) category")
        let version = try text(dict["version"], "\(at) version")
        let urlText = try text(dict["downloadUrl"], "\(at) downloadUrl")
        guard let url = URL(string: urlText), url.scheme == "https", url.host() != nil else {
            throw CatalogError(reason: "\(at) downloadUrl is not an https URL")
        }
        guard let type = InstallerType(rawValue: try text(dict["installerType"], "\(at) installerType")) else {
            throw CatalogError(reason: "\(at) installerType is not app or pkg")
        }
        let bundles = try strings(dict["appBundles"], "\(at) appBundles")
        guard !bundles.isEmpty, bundles.allSatisfy({ $0.hasSuffix(".app") && !$0.contains("/") }) else {
            throw CatalogError(reason: "\(at) appBundles must be .app names")
        }
        try checkLeftovers(dict["leftoverPaths"], at)
        try checkPkgutilIds(dict["pkgutilIds"], at)
        return CatalogApp(
            name: name, category: category, downloadURL: url, version: version,
            installerType: type, appBundles: bundles, sha256: try checksum(dict["sha256"], at)
        )
    }

    private static func text(_ value: Any?, _ label: String) throws -> String {
        guard let s = value as? String, !s.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CatalogError(reason: "\(label) is not a non-empty string")
        }
        return s
    }

    private static func strings(_ value: Any?, _ label: String) throws -> [String] {
        guard let list = value as? [Any] else { throw CatalogError(reason: "\(label) is not a list") }
        return try list.map { try text($0, label) }
    }

    private static func checksum(_ value: Any?, _ at: String) throws -> String? {
        if value is NSNull { return nil }
        let s = try text(value, "\(at) sha256")
        guard s.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil else {
            throw CatalogError(reason: "\(at) sha256 is not 64 hex characters")
        }
        return s
    }

    private static func checkLeftovers(_ value: Any?, _ at: String) throws {
        guard let list = value as? [Any] else { throw CatalogError(reason: "\(at) leftoverPaths is not a list") }
        for item in list {
            guard let entry = item as? [String: Any], Set(entry.keys) == leftoverKeys else {
                throw CatalogError(reason: "\(at) leftoverPaths entry has a missing or unknown key")
            }
            let path = try text(entry["path"], "\(at) leftover path")
            if let problem = pathProblem(path) { throw CatalogError(reason: "\(at) leftover path \(problem)") }
            guard let from = entry["from"] as? String, leftoverActions.contains(from) else {
                throw CatalogError(reason: "\(at) leftover from is not delete, trash or rmdir")
            }
        }
    }

    private static let protectedRoots: Set<String> = [
        "/", "~", "~/library", "/library", "/applications", "/system", "/usr", "/etc", "/private",
        "/var", "/users", "/opt", "/bin", "/sbin", "/tmp", "/volumes",
        "~/library/application support", "~/library/preferences", "~/library/caches",
        "~/library/containers", "~/library/group containers",
        "/library/application support", "/library/preferences", "/library/caches",
        "/library/containers", "/library/group containers",
        "~/library/logs", "~/library/application scripts", "~/library/saved application state",
        "~/library/httpstorages", "~/library/launchagents", "~/library/webkit", "~/library/cookies",
        "/library/launchdaemons", "/library/launchagents", "/library/logs",
        "/library/privilegedhelpertools", "/library/internet plug-ins",
    ]

    private static func pathProblem(_ path: String) -> String? {
        guard path.hasPrefix("~/") || path.hasPrefix("/") else { return "must start with ~/ or /" }
        if path.contains("#{") || path.contains("${") || path.contains("..") { return "holds #{, ${ or .." }
        if path.hasSuffix("/") { return "ends with /" }
        let lower = path.lowercased()
        if lower == "/users" || lower.hasPrefix("/users/") { return "is under /Users" }
        if protectedRoots.contains(lower) { return "is a protected root" }
        let segments = Array(path.split(separator: "/", omittingEmptySubsequences: false).dropFirst())
        if segments.contains(where: { $0.isEmpty }) { return "has an empty segment" }
        if segments.dropLast().contains(where: { $0.contains("*") }) { return "has a wildcard before the last segment" }
        if path.hasPrefix("~/"), segments[0].contains("*") { return "has a wildcard directly under ~" }
        if path.hasPrefix("/"), segments.count < 2 { return "is too shallow" }
        let parent = path[..<path.range(of: "/", options: .backwards)!.lowerBound].lowercased()
        if protectedRoots.contains(parent), segments[segments.count - 1].allSatisfy({ $0 == "*" }) {
            return "matches everything under a protected root"
        }
        return nil
    }

    private static func checkPkgutilIds(_ value: Any?, _ at: String) throws {
        guard let list = value as? [Any] else { throw CatalogError(reason: "\(at) pkgutilIds is not a list") }
        for item in list {
            guard let entry = item as? [String: Any], Set(entry.keys) == pkgutilKeys,
                  entry["pattern"] is Bool else {
                throw CatalogError(reason: "\(at) pkgutilIds entry has a missing or unknown key")
            }
            _ = try text(entry["id"], "\(at) pkgutil id")
        }
    }
}
