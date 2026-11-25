import Foundation

final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    let progress: @Sendable (Double?) -> Void

    init(progress: @escaping @Sendable (Double?) -> Void) {
        self.progress = progress
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        request.url?.scheme == "https" ? request : nil
    }

    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64
    ) {
        progress(totalBytesExpectedToWrite > 0 ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : nil)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
}

enum Downloader {
    static func fetch(
        _ url: URL, into folder: URL, progress: @escaping @Sendable (Double?) -> Void
    ) async throws -> URL {
        let session = URLSession(configuration: Network.configuration(timeout: 60))
        defer { session.finishTasksAndInvalidate() }
        let (temporary, response) = try await session.download(from: url, delegate: DownloadDelegate(progress: progress))
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            try? FileManager.default.removeItem(at: temporary)
            throw Refusal(reason: "The vendor's server did not return the file")
        }
        let file = folder.appending(path: "download")
        try FileManager.default.moveItem(at: temporary, to: file)
        return file
    }
}
