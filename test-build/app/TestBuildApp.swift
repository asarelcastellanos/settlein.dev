import SwiftUI

struct ContentView: View {
    @State private var locateReport = "Reading..."
    @State private var installReport = ""
    @State private var running = false
    @State private var stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "")

    private var combined: String {
        installReport.isEmpty ? locateReport : locateReport + "\n" + installReport
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                Text(combined)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Button("Install and remove test app") {
                    running = true
                    Task {
                        installReport = await runInstallRemoveTest()
                        write()
                        running = false
                    }
                }
                .disabled(running)
                Text("Report: \(reportFileURL(stamp: stamp).path)")
                    .font(.caption)
                    .textSelection(.enabled)
            }
        }
        .padding()
        .frame(minWidth: 760, minHeight: 560)
        .task {
            locateReport = await Task.detached { buildLocateReport() }.value
            write()
        }
    }

    private func write() {
        try? combined.write(to: reportFileURL(stamp: stamp), atomically: true, encoding: .utf8)
    }
}

@main
struct TestBuildApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
