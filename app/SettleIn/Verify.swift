import CryptoKit
import Foundation
import Security

enum Verify {
    static let developerIDNotarized = """
    anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists \
    and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and notarized
    """

    static func sha256(of file: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: file)
        defer { try? handle.close() }
        var hasher = SHA256()
        while let chunk = try handle.read(upToCount: 1 << 20), !chunk.isEmpty {
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    static func signatureProblem(of bundle: URL) -> String? {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(bundle as CFURL, [], &code) == errSecSuccess, let code else {
            return "The signature could not be read"
        }
        let flags = SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate | kSecCSCheckNestedCode)
        let intact = SecStaticCodeCheckValidityWithErrors(code, flags, nil, nil)
        if intact == errSecCSUnsigned { return "It is not signed" }
        if intact != errSecSuccess { return "The signature is broken or the app was modified" }
        var requirement: SecRequirement?
        guard SecRequirementCreateWithString(developerIDNotarized as CFString, [], &requirement) == errSecSuccess,
              let requirement else {
            return "The signature check could not start"
        }
        let result = SecStaticCodeCheckValidityWithErrors(code, flags, requirement, nil)
        return result == errSecSuccess ? nil : "It does not have a valid Developer ID signature with Apple notarization"
    }
}
