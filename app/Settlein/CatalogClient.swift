import Foundation

final class SameHostOnly: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        request.url?.scheme == "https" && request.url?.host() == CatalogClient.host ? request : nil
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
        #endif
        return try CatalogParser.parse(try await fetch())
    }

    private static func fetch() async throws -> Data {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config, delegate: SameHostOnly(), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200, http.url?.host() == host else {
            throw CatalogError(reason: "settlein.dev answered with an unexpected response")
        }
        return data
    }
}
