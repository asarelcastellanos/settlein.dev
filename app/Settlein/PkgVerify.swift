import Foundation

enum PkgVerify {
    static func check(_ package: URL) async throws {
        let signature = await Tools.run("/usr/sbin/pkgutil", ["--check-signature", package.path])
        guard signature.status == 0, signature.output.contains("Developer ID Installer") else {
            throw Refusal(reason: "Signature check failed. The package does not have a valid Developer ID Installer signature")
        }
        guard signature.output.contains("Notarization: trusted by the Apple notary service") else {
            throw Refusal(reason: "Signature check failed. The package is not notarized by Apple")
        }
        let assessment = await Tools.run("/usr/sbin/spctl", ["-a", "-t", "install", "-vv", package.path])
        guard assessment.status == 0, assessment.output.contains("source=Notarized Developer ID") else {
            throw Refusal(reason: "Signature check failed. macOS does not accept the package as a notarized Developer ID installer")
        }
    }
}
