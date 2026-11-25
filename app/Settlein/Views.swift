import SwiftUI

@main
struct SettleinApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .frame(minWidth: 520, minHeight: 360)
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
            MessageView(title: "Nothing selected", detail: "Choose apps on settlein.dev, then open Settlein again.")
        case .confirm(let rows):
            ConfirmationView(rows: rows, approve: model.approve)
        case .allInstalled:
            MessageView(title: "Nothing to install", detail: "Every selected app is already installed.")
        case .approved(let toInstall, let skipped):
            ApprovedView(toInstall: toInstall, skipped: skipped)
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
            } else if row.app.installerType == .pkg {
                Label("Opens Apple's Installer", systemImage: "shippingbox")
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

struct ApprovedView: View {
    let toInstall: [CatalogApp]
    let skipped: [CatalogApp]

    var body: some View {
        VStack(spacing: 12) {
            Text("Approved").font(.title2)
            Text("Installing is not built yet. Nothing was downloaded or changed.")
                .foregroundStyle(.secondary)
            Text("\(toInstall.count) to install, \(skipped.count) already installed")
            Button("Close") { NSApplication.shared.terminate(nil) }.keyboardShortcut(.defaultAction)
        }
        .padding()
    }
}
