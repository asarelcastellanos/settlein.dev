import Foundation

enum PkgVerify {
    static func check(_ package: URL) async throws {
        let signature = await Tools.run("/usr/sbin/pkgutil", ["--check-signature", package.path])
        guard signature.status == 0, let lines = signatureLines(signature.output),
              lines.contains("Status: signed by a developer certificate issued by Apple for distribution"),
              firstCertificate(in: lines)?.hasPrefix("Developer ID Installer:") == true else {
            throw Refusal(reason: "Signature check failed. The package does not have a valid Developer ID Installer signature")
        }
        guard lines.contains("Notarization: trusted by the Apple notary service") else {
            throw Refusal(reason: "Signature check failed. The package is not notarized by Apple")
        }
        let assessment = await Tools.run("/usr/sbin/spctl", ["-a", "-t", "install", "-vv", package.path])
        guard assessment.status == 0, trimmedLines(assessment.output).contains("source=Notarized Developer ID") else {
            throw Refusal(reason: "Signature check failed. macOS does not accept the package as a notarized Developer ID installer")
        }
    }

    static func signatureLines(_ output: String) -> [String]? {
        let lines = trimmedLines(output)
        guard let header = lines.firstIndex(where: { $0.hasPrefix("Package \"") && $0.hasSuffix("\":") }) else { return nil }
        return Array(lines[(header + 1)...])
    }

    static func firstCertificate(in lines: [String]) -> String? {
        guard let chain = lines.firstIndex(of: "Certificate Chain:"), chain + 1 < lines.count else { return nil }
        let first = lines[chain + 1]
        guard first.hasPrefix("1. ") else { return nil }
        return String(first.dropFirst(3))
    }

    private static func trimmedLines(_ output: String) -> [String] {
        output.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
