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
    @FocusState private var opener: RunPanel?

    var body: some View {
        screen
            .centredPanel(
                isPresented: Binding(get: { model.panel != nil }, set: { if !$0 { model.panel = nil } }),
                opener: $opener,
                openerID: model.panelOpener,
                destructive: model.panel == .cancel
            ) { RunPanelContent(model: model) }
    }

    @ViewBuilder
    private var screen: some View {
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
            PickView(pick: pick, showIcon: model.firstLaunch, back: model.hasRecord ? { model.openInstalled() } : nil, install: model.installTicked)
        case .installed(let content):
            InstalledView(content: content, addApps: { model.openPick() }, retry: { Task { await model.launch() } })
        case .installing(let run):
            InstallView(run: run, model: model, opener: $opener)
        }
    }
}
