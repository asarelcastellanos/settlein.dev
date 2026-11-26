import Foundation

final class DownloadDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let destination: URL
    private let ceiling: Int64
    private let freeSpace: Int64?
    private let progress: @Sendable (Double?) -> Void
    private var continuation: CheckedContinuation<Void, Error>?
    private var handle: FileHandle?
    private var expected: Int64 = 0
    private var received: Int64 = 0
    private var refusal: Refusal?

    init(destination: URL, ceiling: Int64, freeSpace: Int64?, progress: @escaping @Sendable (Double?) -> Void) {
        self.destination = destination
        self.ceiling = ceiling
        self.freeSpace = freeSpace
        self.progress = progress
    }

    func run(_ task: URLSessionDataTask) async throws {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                task.resume()
            }
        } onCancel: {
            task.cancel()
        }
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        request.url?.scheme == "https" ? request : nil
    }

    func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            refusal = Refusal(reason: "The vendor’s server did not return the file")
            return .cancel
        }
        expected = response.expectedContentLength
        if expected > ceiling {
            refusal = Refusal(reason: "The download is larger than the size limit")
            return .cancel
        }
        if expected > 0, let freeSpace, expected > freeSpace {
            refusal = Refusal(reason: "The download needs more space than is free on this Mac")
            return .cancel
        }
        guard FileManager.default.createFile(atPath: destination.path, contents: nil),
              let opened = try? FileHandle(forWritingTo: destination) else {
            refusal = Refusal(reason: "SettleIn could not create a temporary file for the download")
            return .cancel
        }
        handle = opened
        return .allow
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received += Int64(data.count)
        if received > ceiling {
            refusal = Refusal(reason: "The download is larger than the size limit")
            return dataTask.cancel()
        }
        if expected > 0, received > expected {
            refusal = Refusal(reason: "The server sent more data than it declared")
            return dataTask.cancel()
        }
        do {
            try handle?.write(contentsOf: data)
        } catch {
            refusal = Refusal(reason: "SettleIn could not write the download. \(error.localizedDescription)")
            return dataTask.cancel()
        }
        progress(expected > 0 ? Double(received) / Double(expected) : nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        try? handle?.close()
        handle = nil
        if let refusal {
            try? FileManager.default.removeItem(at: destination)
            continuation?.resume(throwing: refusal)
        } else if let error {
            try? FileManager.default.removeItem(at: destination)
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume()
        }
        continuation = nil
    }
}

enum Downloader {
    static let defaultCeiling: Int64 = 8_000_000_000

    static func fetch(
        _ url: URL, into folder: URL, ceiling: Int64 = defaultCeiling,
        progress: @escaping @Sendable (Double?) -> Void
    ) async throws -> URL {
        let file = folder.appending(path: "download")
        let free = try? FileManager.default.temporaryDirectory
            .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage
        let delegate = DownloadDelegate(destination: file, ceiling: ceiling, freeSpace: free, progress: progress)
        let session = URLSession(configuration: Network.configuration(timeout: 60), delegate: delegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        try await delegate.run(session.dataTask(with: url))
        return file
    }
}
