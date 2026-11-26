import Foundation

final class SameHostOnly: NSObject, URLSessionTaskDelegate {
    let host: String

    init(host: String) {
        self.host = host
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        request.url?.scheme == "https" && request.url?.host() == host ? request : nil
    }
}

enum CatalogClient {
    static let host = "settlein.dev"
    static let url = URL(string: "https://settlein.dev/catalog.json")!

    static func load() async throws -> [CatalogApp] {
        #if DEBUG
        if let path = UserDefaults.standard.string(forKey: "catalogFile") {
            return try CatalogParser.parse(try Data(contentsOf: URL(fileURLWithPath: path)))
        }
        if let text = UserDefaults.standard.string(forKey: "catalogURL"), let override = URL(string: text) {
            return try CatalogParser.parse(try await fetch(override))
        }
        #endif
        return try CatalogParser.parse(try await fetch(url))
    }

    private static func fetch(_ source: URL) async throws -> Data {
        let session = URLSession(configuration: Network.configuration(timeout: 15), delegate: SameHostOnly(host: source.host() ?? host), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        let (data, response) = try await session.data(from: source)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200, http.url?.host() == source.host() else {
            throw CatalogError(reason: "settlein.dev answered with an unexpected response")
        }
        return data
    }
}
