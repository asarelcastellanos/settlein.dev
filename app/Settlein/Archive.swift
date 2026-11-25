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
        defer { for point in points { detach(point) } }
        guard attach.status == 0, !points.isEmpty else {
            throw Refusal(reason: "The download is not a zip file or a disk image Settlein can open")
        }
        var copies: [URL] = []
        for name in names {
            guard let source = points.map({ URL(filePath: $0).appending(path: name) })
                .first(where: { FileManager.default.fileExists(atPath: $0.path) }) else {
                throw Refusal(reason: "The download does not hold \(name)")
            }
            let copy = unpacked.appending(path: name)
            let result = await Tools.run("/usr/bin/ditto", [source.path, copy.path])
            guard result.status == 0 else { throw Refusal(reason: "Settlein could not copy \(name) out of the disk image") }
            copies.append(copy)
        }
        return copies
    }

    private static func locate(_ names: [String], in folder: URL) throws -> [URL] {
        try names.map { name in
            let url = folder.appending(path: name)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw Refusal(reason: "The download does not hold \(name)")
            }
            return url
        }
    }

    private static func mountPoints(_ output: String) -> [String] {
        guard let start = output.range(of: "<?xml"),
              let data = String(output[start.lowerBound...]).data(using: .utf8),
              let root = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let entities = root["system-entities"] as? [[String: Any]] else { return [] }
        return entities.compactMap { $0["mount-point"] as? String }
    }

    private static func detach(_ point: String) {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/hdiutil")
        process.arguments = ["detach", "-force", point]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }
}
