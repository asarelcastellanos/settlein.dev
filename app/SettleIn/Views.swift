import SwiftUI

@main
struct SettleInApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .frame(minWidth: 520, minHeight: 360)
                .preferredColorScheme(.light)
                .task { await model.load() }
        }
    }
}

struct RootView: View {
    let model: AppModel

    var body: some View {
        switch model.screen {
        case .loading:
            ProgressView("Reading the catalog")
        case .unreachable(let reason):
            UnreachableView(reason: reason) { Task { await model.load() } }
        case .nothingSelected:
            MessageView(title: "Nothing selected", detail: "Choose apps on settlein.dev, then open SettleIn again.")
        case .confirm(let rows):
            ConfirmationView(rows: rows, approve: model.approve)
        case .allInstalled:
            MessageView(title: "Nothing to install", detail: "Every selected app is already installed.")
        case .installing(let run):
            InstallView(run: run)
                .task { await run.start() }
        }
    }
}

struct ConfirmationView: View {
    let rows: [Row]
    let approve: () -> Void

    private var installCount: Int { rows.filter { !$0.installed }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Install \(installCount) \(installCount == 1 ? "app" : "apps")?")
                .font(.title2)
            Text("Nothing downloads until you approve.")
                .foregroundStyle(.secondary)
            List(rows) { AppRowView(row: $0) }
            HStack {
                Spacer()
                Button("Cancel") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut(.cancelAction)
                Button("Approve", action: approve)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
}

struct AppRowView: View {
    let row: Row

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(row.app.name)
                Text(status).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if row.installed {
                Label("Already installed", systemImage: "checkmark.circle")
            }
        }
    }

    private var status: String {
        if row.installed { return "Already installed, will skip" }
        return row.app.installerType == .pkg ? "Opens Apple's Installer" : "Will install"
    }
}

struct UnreachableView: View {
    let reason: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Cannot reach the catalog").font(.title2)
            Text(reason).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Try again", action: retry).keyboardShortcut(.defaultAction)
        }
        .padding()
    }
}

struct MessageView: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.title2)
            Text(detail).foregroundStyle(.secondary)
            Button("Close") { NSApplication.shared.terminate(nil) }.keyboardShortcut(.defaultAction)
        }
        .padding()
    }
}

struct InstallView: View {
    let run: InstallRun

    var body: some View {
        if run.finished {
            FinishedView(run: run)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Installing").font(.title2)
                ProgressView(value: Double(run.settled), total: Double(run.items.count))
                Text("\(run.settled) of \(run.items.count) done").foregroundStyle(.secondary)
                List(run.items) { RunRowView(item: $0) }
            }
            .padding()
        }
    }
}

struct RunRowView: View {
    let item: RunItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.app.name)
                Spacer()
                Text(tag).font(.caption)
            }
            if case .downloading(let fraction?) = item.state {
                ProgressView(value: fraction)
            }
            Text(detail).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var tag: String {
        switch item.state {
        case .waiting: "Waiting"
        case .downloading: "Downloading"
        case .verifying: "Verifying"
        case .installing: "Installing"
        case .done: "Done"
        case .refused: "Refused"
        case .opening: "Opening"
        case .waitingInInstaller: "In Installer"
        }
    }

    private var detail: String {
        switch item.state {
        case .waiting: "Waiting"
        case .downloading(let fraction?): "Downloading, \(Int(fraction * 100))%"
        case .downloading(nil): "Downloading"
        case .verifying: "Verifying"
        case .installing: "Installing"
        case .done: "Done"
        case .refused(let reason): "Refused. \(reason)"
        case .opening: "Opening in Apple's Installer"
        case .waitingInInstaller: "Verified. Waiting in Apple's Installer"
        }
    }
}

struct FinishedView: View {
    let run: InstallRun

    private func apps(_ match: (ItemState) -> Bool) -> [CatalogApp] {
        run.items.filter { match($0.state) }.map(\.app)
    }

    private var refused: [RunItem] {
        run.items.filter { if case .refused = $0.state { true } else { false } }
    }

    private var installed: [CatalogApp] { apps { $0 == .done } }
    private var waiting: [CatalogApp] { apps { $0 == .waitingInInstaller } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary).font(.title2)
            List {
                section("Installed in \(run.folder.path)", installed.map { ($0.name, nil) })
                section("Opened in Apple's Installer", waiting.map { ($0.name, "Verified. SettleIn cannot tell whether you finished the install") })
                section("Skipped, already installed", run.skipped.map { ($0.name, nil) })
                section("Refused", refused.map { item in
                    if case .refused(let reason) = item.state { (item.app.name, reason) } else { (item.app.name, nil) }
                })
            }
            HStack {
                Spacer()
                Button("Done") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }

    private var summary: String {
        "\(installed.count) installed, \(waiting.count) opened in Apple's Installer, \(run.skipped.count) skipped, \(refused.count) refused"
    }

    @ViewBuilder
    private func section(_ title: String, _ rows: [(String, String?)]) -> some View {
        if !rows.isEmpty {
            Section(title) {
                ForEach(rows, id: \.0) { name, detail in
                    VStack(alignment: .leading) {
                        Text(name)
                        if let detail { Text(detail).font(.caption).foregroundStyle(.secondary) }
                    }
                }
            }
        }
    }
}
