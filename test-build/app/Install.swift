import CryptoKit
import Foundation

private let sourceURL = URL(string: "https://www.freemacsoft.net/downloads/AppCleaner_3.7.zip")!
private let sourceSHA256 = "3d7fa6146fb57da955dca408587fc658ac14aeb86eda7907763ae66397c9e65e"
private let bundleName = "AppCleaner.app"

func runInstallRemoveTest() async -> String {
    var lines = ["S8 install and remove test", "source: \(sourceURL.absoluteString)"]
    let fileManager = FileManager.default
    let work = fileManager.temporaryDirectory.appendingPathComponent("settlein-s8-\(UUID().uuidString)")
    defer { try? fileManager.removeItem(at: work) }
    let targetFolder = "/Applications"
    guard fileManager.isWritableFile(atPath: targetFolder) else {
        lines.append("S8 not run: /Applications not writable by this user")
        return lines.joined(separator: "\n") + "\n"
    }
    do {
        try fileManager.createDirectory(at: work, withIntermediateDirectories: true)
        let (temporary, _) = try await URLSession.shared.download(from: sourceURL)
        let zip = work.appendingPathComponent("app.zip")
        try fileManager.moveItem(at: temporary, to: zip)
        let digest = SHA256.hash(data: try Data(contentsOf: zip)).map { String(format: "%02x", $0) }.joined()
        let matches = digest == sourceSHA256
        lines.append("sha256 matches Homebrew cask: \(matches)")
        guard matches else {
            lines.append("S8 stopped before install: SHA-256 \(digest) does not match the pinned value")
            return lines.joined(separator: "\n") + "\n"
        }
        let unpacked = work.appendingPathComponent("unpacked")
        let ditto = runTool("/usr/bin/ditto", ["-x", "-k", zip.path, unpacked.path])
        lines.append("unzip status: \(ditto.status)")
        guard ditto.status == 0 else {
            lines.append("S8 stopped before install: unzip failed, \(ditto.output.prefix(200))")
            return lines.joined(separator: "\n") + "\n"
        }
        let staged = unpacked.appendingPathComponent(bundleName)

        let signature = runTool("/usr/bin/codesign", ["-dv", staged.path])
        let team = signature.output.split(separator: "\n").first { $0.hasPrefix("TeamIdentifier=") }
        lines.append("downloaded app \(team.map(String.init) ?? "TeamIdentifier unknown")")

        let target = targetFolder + "/" + bundleName
        lines.append("install target: \(target)")
        if fileManager.fileExists(atPath: target) {
            lines.append("install: skipped, \(target) already exists and was not installed by this test")
            return lines.joined(separator: "\n") + "\n"
        }
        do {
            try fileManager.copyItem(at: staged, to: URL(fileURLWithPath: target))
            lines.append("install: ok")
        } catch {
            lines.append("install: failed, \(describe(error))")
            if fileManager.fileExists(atPath: target) {
                do {
                    try fileManager.removeItem(atPath: target)
                    lines.append("partial bundle removed")
                } catch {
                    lines.append("partial bundle removal failed, \(describe(error))")
                }
            }
            return lines.joined(separator: "\n") + "\n"
        }
        do {
            try fileManager.removeItem(atPath: target)
            lines.append("remove: ok")
        } catch {
            lines.append("remove: failed, \(describe(error))")
        }
        lines.append("bundle still exists after remove: \(fileManager.fileExists(atPath: target))")
    } catch {
        lines.append("setup failed: \(describe(error))")
    }
    return lines.joined(separator: "\n") + "\n"
}

private func describe(_ error: Error) -> String {
    let ns = error as NSError
    var text = "\(ns.domain) \(ns.code): \(ns.localizedDescription)"
    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
        text += " (underlying \(underlying.domain) \(underlying.code): \(underlying.localizedDescription))"
    }
    return text
}
