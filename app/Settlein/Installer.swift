import AppKit
import CoreServices
import Foundation

struct Refusal: Error {
    let reason: String
}

enum InstallStep {
    case downloading(Double?)
    case verifying
    case installing
    case opening
}

enum Installer {
    static func destination() -> URL {
        let system = URL(filePath: "/Applications", directoryHint: .isDirectory)
        if FileManager.default.isWritableFile(atPath: system.path) { return system }
        return URL.homeDirectory.appending(path: "Applications", directoryHint: .isDirectory)
    }

    static func install(
        _ app: CatalogApp, into folder: URL, step: @escaping @Sendable (InstallStep) -> Void
    ) async throws {
        let fileManager = FileManager.default
        let work = fileManager.temporaryDirectory.appending(path: "settlein-\(UUID().uuidString)", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: work, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: work) }

        step(.downloading(nil))
        let file = try await Downloader.fetch(app.downloadURL, into: work) { step(.downloading($0)) }

        step(.verifying)
        if let expected = app.sha256, try Verify.sha256(of: file) != expected {
            throw Refusal(reason: "Checksum does not match")
        }
        if app.installerType == .pkg {
            let package = try await Archive.package(in: file, workFolder: work)
            try await PkgVerify.check(package)
            step(.opening)
            try await openPackage(package, from: app.downloadURL)
            return
        }
        let bundles = try await Archive.bundles(in: file, named: app.appBundles, workFolder: work)
        for bundle in bundles {
            if let problem = Verify.signatureProblem(of: bundle) {
                throw Refusal(reason: "Signature check failed. \(problem)")
            }
        }

        step(.installing)
        try place(bundles, in: folder, from: app.downloadURL)
    }

    static let keptPrefix = "settlein-pkg-"
    static let keptLifetime: TimeInterval = 24 * 60 * 60
    static let installerApp = URL(filePath: "/System/Library/CoreServices/Installer.app")

    private static func openPackage(_ package: URL, from source: URL) async throws {
        let fileManager = FileManager.default
        let kept = fileManager.temporaryDirectory.appending(path: "\(keptPrefix)\(UUID().uuidString)", directoryHint: .isDirectory)
        let target = kept.appending(path: package.lastPathComponent)
        do {
            try fileManager.createDirectory(at: kept, withIntermediateDirectories: true)
            try quarantine(package, source: source)
            try fileManager.moveItem(at: package, to: target)
            _ = try await NSWorkspace.shared.open([target], withApplicationAt: installerApp, configuration: NSWorkspace.OpenConfiguration())
        } catch {
            try? fileManager.removeItem(at: kept)
            throw Refusal(reason: "Settlein could not open the package in Apple's Installer. \(error.localizedDescription)")
        }
    }

    static func removeStalePackages() {
        let fileManager = FileManager.default
        let entries = (try? fileManager.contentsOfDirectory(
            at: fileManager.temporaryDirectory, includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey, .isSymbolicLinkKey])) ?? []
        for entry in entries where entry.lastPathComponent.hasPrefix(keptPrefix) {
            let values = try? entry.resourceValues(forKeys: [.contentModificationDateKey, .isDirectoryKey, .isSymbolicLinkKey])
            guard values?.isDirectory == true, values?.isSymbolicLink != true else { continue }
            if let modified = values?.contentModificationDate, Date().timeIntervalSince(modified) > keptLifetime {
                try? fileManager.removeItem(at: entry)
            }
        }
    }

    private static func place(_ bundles: [URL], in folder: URL, from source: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        for bundle in bundles where fileManager.fileExists(atPath: folder.appending(path: bundle.lastPathComponent).path) {
            throw Refusal(reason: "\(bundle.lastPathComponent) already exists in \(folder.path)")
        }
        var placed: [URL] = []
        do {
            for bundle in bundles {
                try quarantine(bundle, source: source)
                let target = folder.appending(path: bundle.lastPathComponent)
                placed.append(target)
                try fileManager.moveItem(at: bundle, to: target)
            }
        } catch {
            let last = placed.last
            let existed = last != nil && (error as NSError).code == NSFileWriteFileExistsError
            for target in placed where !(existed && target == last) { try? fileManager.removeItem(at: target) }
            if existed, let last {
                throw Refusal(reason: "\(last.lastPathComponent) already exists in \(folder.path)")
            }
            throw Refusal(reason: "Settlein could not write to \(folder.path). \(error.localizedDescription)")
        }
    }

    private static func quarantine(_ bundle: URL, source: URL) throws {
        var values = URLResourceValues()
        values.quarantineProperties = [
            kLSQuarantineTypeKey as String: kLSQuarantineTypeWebDownload as String,
            kLSQuarantineAgentNameKey as String: "Settlein",
            kLSQuarantineDataURLKey as String: source.absoluteString,
        ]
        var url = bundle
        try url.setResourceValues(values)
    }
}
