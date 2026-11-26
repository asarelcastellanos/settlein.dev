import SwiftUI

@main
struct SettleInApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        Window("SettleIn", id: "main") {
            RootView(model: model)
                .frame(minWidth: 720, minHeight: 520)
                .preferredColorScheme(.light)
                .containerBackground(for: .window) { WindowGround() }
                .task { await model.launch() }
        }
        .defaultSize(width: 1100, height: 700)
        .commands { SettleInCommands(model: model) }
    }
}

struct RootView: View {
    let model: AppModel

    var body: some View {
        switch model.screen {
        case .loading(let destination):
            switch destination {
            case .pick: PickLoadingView()
            case .installed: InstalledLoadingView()
            case .installing: Color.clear
            }
        case .unreachable(let kind):
            UnreachableView(kind: kind) { Task { await model.retry() } }
        case .pick(let pick):
            PickView(pick: pick, back: model.hasRecord ? { model.openInstalled() } : nil, install: model.installTicked)
        case .installed(let content):
            InstalledView(content: content, addApps: { model.openPick() }, retry: { Task { await model.launch() } })
        case .installing(let run):
            InstallView(run: run)
        }
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
        case .opening: "Opening in Apple’s Installer"
        case .waitingInInstaller: "Verified. Waiting in Apple’s Installer"
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
            if run.recordFailed {
                Text("SettleIn couldn’t save its record of these apps. They won’t be listed under Installed by SettleIn. Make sure SettleIn’s folder can be written to.")
                    .foregroundStyle(Color.SI.warning)
            }
            List {
                section("Installed in \(run.folder.path)", installed.map { ($0.name, nil) })
                section("Opened in Apple’s Installer", waiting.map { ($0.name, "Verified. SettleIn cannot tell whether you finished the install") })
                section("Skipped, already installed", run.skipped.map { ($0.name, nil) })
                section("Refused", refused.map { item in
                    if case .refused(let reason) = item.state { (item.app.name, reason) } else { (item.app.name, nil) }
                })
            }
            HStack {
                Spacer()
                Button("Done") { NSApplication.shared.terminate(nil) }
                    .focusRing()
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }

    private var summary: String {
        "\(installed.count) installed, \(waiting.count) opened in Apple’s Installer, \(run.skipped.count) skipped, \(refused.count) refused"
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
