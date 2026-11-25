import Foundation

enum Archive {
    static func bundles(in file: URL, named names: [String], workFolder: URL) async throws -> [URL] {
        let unpacked = workFolder.appending(path: "unpacked", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: unpacked, withIntermediateDirectories: true)
        if try isZip(file) {
            let result = await Tools.run("/usr/bin/ditto", ["-x", "-k", file.path, unpacked.path])
            guard result.status == 0 else { throw Refusal(reason: "The download is not a readable zip file") }
            return try locate(names, in: unpacked)
        }
        return try await fromDiskImage(file, names: names, workFolder: workFolder, unpacked: unpacked)
    }

    private static func isZip(_ file: URL) throws -> Bool {
        let handle = try FileHandle(forReadingFrom: file)
        defer { try? handle.close() }
        return try handle.read(upToCount: 4) == Data([0x50, 0x4B, 0x03, 0x04])
    }

    private static func fromDiskImage(
        _ file: URL, names: [String], workFolder: URL, unpacked: URL
    ) async throws -> [URL] {
        let mounts = workFolder.appending(path: "mounts", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: mounts, withIntermediateDirectories: true)
        let attach = await Tools.run("/usr/bin/hdiutil", [
            "attach", "-nobrowse", "-readonly", "-noautoopen", "-plist", "-mountrandom", mounts.path, file.path,
        ])
        let points = mountPoints(attach.output)
        let copies: [URL]
        do {
            guard attach.status == 0, !points.isEmpty else {
                throw Refusal(reason: "The download is not a zip file or a disk image Settlein can open")
            }
            copies = try await copyBundles(names, from: points, to: unpacked)
        } catch {
            try detachAll(points)
            throw error
        }
        try detachAll(points)
        return copies
    }

    private static func copyBundles(_ names: [String], from points: [String], to unpacked: URL) async throws -> [URL] {
        var copies: [URL] = []
        for name in names {
            guard let source = points.map({ URL(filePath: $0).appending(path: name) })
                .first(where: { exists($0) }) else {
                throw Refusal(reason: "The download does not hold \(name)")
            }
            try requirePlainBundle(source, name: name)
            let copy = unpacked.appending(path: name)
            let result = await Tools.run("/usr/bin/ditto", [source.path, copy.path])
            guard result.status == 0 else { throw Refusal(reason: "Settlein could not copy \(name) out of the disk image") }
            copies.append(copy)
        }
        return copies
    }

    private static func detachAll(_ points: [String]) throws {
        for point in points where !detach(point, arguments: ["detach", point]) && !detach(point, arguments: ["detach", "-force", point]) {
            throw Refusal(reason: "Settlein could not eject the disk image at \(point)")
        }
    }

    private static func locate(_ names: [String], in folder: URL) throws -> [URL] {
        try names.map { name in
            let url = folder.appending(path: name)
            guard exists(url) else {
                throw Refusal(reason: "The download does not hold \(name)")
            }
            try requirePlainBundle(url, name: name)
            return url
        }
    }

    private static func exists(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) != nil
    }

    private static func requirePlainBundle(_ url: URL, name: String) throws {
        let values = try? url.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey])
        if values?.isSymbolicLink == true {
            throw Refusal(reason: "\(name) in the download is a link, not an app")
        }
        if values?.isDirectory != true {
            throw Refusal(reason: "\(name) in the download is not an app bundle")
        }
    }

    private static func mountPoints(_ output: String) -> [String] {
        guard let start = output.range(of: "<?xml"),
              let data = String(output[start.lowerBound...]).data(using: .utf8),
              let root = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let entities = root["system-entities"] as? [[String: Any]] else { return [] }
        return entities.compactMap { $0["mount-point"] as? String }
    }

    private static func detach(_ point: String, arguments: [String]) -> Bool {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/hdiutil")
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return false }
        process.waitUntilExit()
        return process.terminationStatus == 0
    }
}
