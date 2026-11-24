import Foundation

func describeFile(_ path: String) -> [String] {
    var lines = ["  path: \(path)", "  file name: \((path as NSString).lastPathComponent)"]
    let attributes = readAttributes(at: path)
    if let froms = attributes.whereFromsRaw {
        for (index, value) in froms.enumerated() {
            lines.append("  kMDItemWhereFroms[\(index)]: \(value)")
        }
    } else {
        lines.append("  kMDItemWhereFroms: absent")
    }
    lines.append("  com.apple.quarantine: \(attributes.quarantine ?? "absent")")
    for error in attributes.errors { lines.append("  attribute error: \(error)") }
    for (index, value) in (attributes.whereFromsRaw ?? []).enumerated() {
        lines.append("  selection from kMDItemWhereFroms[\(index)]: \(selectionFromURL(value)?.joined(separator: ",") ?? "none")")
    }
    return lines
}

func buildLocateReport() -> String {
    var lines: [String] = []
    let bundle = Bundle.main.bundleURL
    lines.append("Settlein test build report (S1, S2)")
    lines.append("date: \(ISO8601DateFormatter().string(from: Date()))")
    lines.append("macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    lines.append("user: \(NSUserName())")
    lines.append("bundle path: \(bundle.path)")

    let moved = translocation(of: bundle)
    lines.append("app translocated: \(moved.isTranslocated)")
    if moved.isTranslocated {
        lines.append("original bundle path: \(moved.originalPath ?? "unavailable")")
    }

    lines.append("")
    lines.append("Own bundle attributes")
    lines.append(contentsOf: describeFile(moved.originalPath ?? bundle.path))

    var candidates: [Candidate] = []
    let origin = URL(fileURLWithPath: moved.originalPath ?? bundle.path)
    let volume = (try? origin.resourceValues(forKeys: [.volumeURLKey]))?.volume?.path ?? "/"
    lines.append("")
    lines.append("Locate: mounted disk image")
    lines.append("  volume of bundle: \(volume)")
    if volume == "/" {
        lines.append("  skipped, the bundle is on the startup volume")
    } else {
        let image = diskImagePath(forVolumeAt: volume)
        lines.append("  \(image.note)")
        lines.append("  image path: \(image.path ?? "none")")
        if let path = image.path { candidates.append(Candidate(method: "disk image", path: path)) }
    }

    let spotlight = spotlightCandidates()
    lines.append("")
    lines.append("Locate: Spotlight where-from search")
    lines.append("  \(spotlight.note)")
    candidates += spotlight.paths.map { Candidate(method: "Spotlight", path: $0) }

    let downloads = downloadsCandidates()
    lines.append("")
    lines.append("Locate: Downloads folder name scan")
    lines.append("  \(downloads.note)")
    candidates += downloads.paths.map { Candidate(method: "Downloads scan", path: $0) }

    var seen = Set<String>()
    lines.append("")
    lines.append("Candidates: \(candidates.count)")
    for candidate in candidates where seen.insert(candidate.path).inserted {
        let methods = candidates.filter { $0.path == candidate.path }.map(\.method).joined(separator: ", ")
        lines.append("")
        lines.append("Candidate found by: \(methods)")
        lines.append(contentsOf: describeFile(candidate.path))
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDirectory), !isDirectory.boolValue {
            do {
                let handle = try FileHandle(forReadingFrom: URL(fileURLWithPath: candidate.path))
                let head = try handle.read(upToCount: 16) ?? Data()
                try handle.close()
                lines.append("  content read: ok, \(head.count) bytes")
            } catch {
                lines.append("  content read: failed, \(error.localizedDescription)")
            }
        } else {
            lines.append("  content read: skipped, not a regular file")
        }
    }
    return lines.joined(separator: "\n") + "\n"
}

func reportFileURL(stamp: String) -> URL {
    let folder = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Logs/SettleinTestBuild")
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    return folder.appendingPathComponent("report-\(stamp).txt")
}
