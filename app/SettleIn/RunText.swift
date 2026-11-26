import Foundation

enum RunText {
    static func apps(_ count: Int) -> String { "\(count) \(count == 1 ? "app" : "apps")" }

    static func names(_ list: [String]) -> String {
        guard list.count > 1, let last = list.last else { return list.first ?? "" }
        return list.dropLast().joined(separator: ", ") + " and " + last
    }

    static func refusal(_ reason: String, short: Bool) -> String {
        let installed = short ? "" : " SettleIn didn’t install it."
        if reason.hasPrefix("Checksum does not match") {
            return "The download doesn’t match the checksum in the catalog." + (short ? "" : " It may be damaged or changed.") + installed
        }
        if reason.hasPrefix("Signature check failed.") {
            if reason.contains("not notarized") { return "The download isn’t notarized by Apple." + installed }
            if reason.hasSuffix("It is not signed") {
                return "The download isn’t signed by its developer." + (short ? "" : " Nothing was installed.")
            }
            return "The download isn’t signed with a valid Developer ID." + installed
        }
        return reason
    }
}
