import Foundation

struct FileAttributes {
    var whereFromsRaw: [String]?
    var quarantine: String?
    var errors: [String]
}

func readAttributes(at path: String) -> FileAttributes {
    var result = FileAttributes(whereFromsRaw: nil, quarantine: nil, errors: [])
    switch readXattr(path, "com.apple.metadata:kMDItemWhereFroms") {
    case .success(let data):
        if let data {
            let value = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            result.whereFromsRaw = value as? [String]
            if result.whereFromsRaw == nil {
                result.errors.append("kMDItemWhereFroms is not a string array")
            }
        }
    case .failure(let message):
        result.errors.append("kMDItemWhereFroms: \(message)")
    }
    switch readXattr(path, "com.apple.quarantine") {
    case .success(let data):
        if let data { result.quarantine = String(decoding: data, as: UTF8.self) }
    case .failure(let message):
        result.errors.append("com.apple.quarantine: \(message)")
    }
    return result
}

enum XattrResult {
    case success(Data?)
    case failure(String)
}

func readXattr(_ path: String, _ name: String) -> XattrResult {
    let size = getxattr(path, name, nil, 0, 0, XATTR_NOFOLLOW)
    if size < 0 {
        if errno == ENOATTR { return .success(nil) }
        return .failure(String(cString: strerror(errno)))
    }
    var buffer = [UInt8](repeating: 0, count: size)
    let read = getxattr(path, name, &buffer, size, 0, XATTR_NOFOLLOW)
    if read < 0 { return .failure(String(cString: strerror(errno))) }
    return .success(Data(buffer.prefix(read)))
}

func selectionFromName(_ fileName: String) -> [String]? {
    var stem = (fileName as NSString).deletingPathExtension
    if let range = stem.range(of: #" \(\d+\)$"#, options: .regularExpression) {
        stem.removeSubrange(range)
    }
    guard stem.hasPrefix("Settlein-") else { return nil }
    return splitSelection(String(stem.dropFirst("Settlein-".count)))
}

func selectionFromURL(_ text: String) -> [String]? {
    guard let items = URLComponents(string: text)?.queryItems,
          let value = items.first(where: { $0.name == "apps" })?.value
    else { return nil }
    return splitSelection(value)
}

private func splitSelection(_ text: String) -> [String]? {
    let parts = text.split(separator: ",").map(String.init)
    return parts.isEmpty ? nil : parts
}
