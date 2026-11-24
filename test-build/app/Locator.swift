import Foundation

struct Candidate {
    var method: String
    var path: String
}

struct Translocation {
    var isTranslocated: Bool
    var originalPath: String?
}

func translocation(of url: URL) -> Translocation {
    guard let handle = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY),
          let isSym = dlsym(handle, "SecTranslocateIsTranslocatedURL"),
          let origSym = dlsym(handle, "SecTranslocateCreateOriginalPathForURL")
    else { return Translocation(isTranslocated: false, originalPath: nil) }
    typealias IsFn = @convention(c) (CFURL, UnsafeMutablePointer<Bool>, UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Bool
    typealias OrigFn = @convention(c) (CFURL, UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Unmanaged<CFURL>?
    var flag = false
    let isFn = unsafeBitCast(isSym, to: IsFn.self)
    guard isFn(url as CFURL, &flag, nil), flag else {
        return Translocation(isTranslocated: false, originalPath: nil)
    }
    let origFn = unsafeBitCast(origSym, to: OrigFn.self)
    let original = origFn(url as CFURL, nil)?.takeRetainedValue() as URL?
    return Translocation(isTranslocated: true, originalPath: original?.path)
}

func runTool(_ path: String, _ arguments: [String]) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    do {
        try process.run()
    } catch {
        return (-1, "\(error)")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return (process.terminationStatus, String(decoding: data, as: UTF8.self))
}

func diskImagePath(forVolumeAt volume: String) -> (path: String?, note: String) {
    let result = runTool("/usr/bin/hdiutil", ["info", "-plist"])
    guard result.status == 0,
          let plist = try? PropertyListSerialization.propertyList(from: Data(result.output.utf8), options: [], format: nil) as? [String: Any],
          let images = plist["images"] as? [[String: Any]]
    else { return (nil, "hdiutil info failed: \(result.output.prefix(200))") }
    for image in images {
        let entities = image["system-entities"] as? [[String: Any]] ?? []
        if entities.contains(where: { ($0["mount-point"] as? String) == volume }) {
            return (image["image-path"] as? String, "matched mount point \(volume)")
        }
    }
    return (nil, "no mounted image has mount point \(volume)")
}

func spotlightCandidates() -> (paths: [String], note: String) {
    let home = NSHomeDirectory()
    let result = runTool("/usr/bin/mdfind", ["-onlyin", home, #"kMDItemWhereFroms == "*Settlein*"c"#])
    guard result.status == 0 else { return ([], "mdfind failed: \(result.output.prefix(200))") }
    let paths = result.output.split(separator: "\n").map(String.init)
    return (paths, "mdfind returned \(paths.count) paths")
}

func downloadsCandidates() -> (paths: [String], note: String) {
    let folder = NSHomeDirectory() + "/Downloads"
    do {
        let names = try FileManager.default.contentsOfDirectory(atPath: folder)
        let hits = names.filter { $0.range(of: #"^Settlein( \([0-9]+\))?\.dmg$"#, options: .regularExpression) != nil }.sorted()
        return (hits.map { folder + "/" + $0 }, "listed \(names.count) entries in \(folder)")
    } catch {
        return ([], "cannot list \(folder): \(error.localizedDescription)")
    }
}
