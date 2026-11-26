import Foundation

struct ToolResult {
    let status: Int32
    let output: String
}

enum Tools {
    static func run(_ path: String, _ arguments: [String]) async -> ToolResult {
        await Task.detached {
            let process = Process()
            process.executableURL = URL(filePath: path)
            process.arguments = arguments
            process.standardInput = FileHandle.nullDevice
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            do {
                try process.run()
            } catch {
                return ToolResult(status: -1, output: error.localizedDescription)
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return ToolResult(status: process.terminationStatus, output: String(decoding: data, as: UTF8.self))
        }.value
    }
}
