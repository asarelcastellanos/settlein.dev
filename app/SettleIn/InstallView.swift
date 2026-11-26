import AppKit
import SwiftUI

private func showInstaller() {
    Task { _ = try? await NSWorkspace.shared.openApplication(at: Installer.installerApp, configuration: NSWorkspace.OpenConfiguration()) }
}

struct InstallView: View {
    let run: InstallRun
    let model: AppModel
    var opener: FocusState<RunPanel?>.Binding

    var body: some View {
        if run.nothingToInstall {
            NothingToInstallView(run: run, model: model)
        } else if run.finished && run.stop != .change {
            FinishedView(run: run, model: model)
        } else {
            running
        }
    }

    private var running: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SISpace.s4) {
                VStack(alignment: .leading, spacing: SISpace.s3) {
                    ScreenHeading(title: "Installing \(RunText.apps(run.items.count))", detail: subtitle)
                    ProgressView(value: Double(run.settled), total: Double(run.items.count))
                        .progressViewStyle(BarProgressStyle())
                }
                RunList(items: run.items, style: .running)
            }
            .padding(.horizontal, SISpace.s6)
            .padding(.top, SISpace.s5)
            .padding(.bottom, SISpace.s5)
        }
        .safeAreaInset(edge: .bottom) {
            GlassBar {
                Text("Each app downloads from its own developer and is checked before it installs.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.SI.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer()
                Button("Change selection") { model.ask(.change) }
                    .buttonStyle(SecondaryButtonStyle())
                    .focused(opener, equals: .change)
                    .focusRing()
                    .disabled(!model.canAsk)
                Button("Cancel") { model.ask(.cancel) }
                    .buttonStyle(SecondaryButtonStyle())
                    .focused(opener, equals: .cancel)
                    .focusRing()
                    .disabled(!model.canAsk)
            }
        }
    }

    private var subtitle: String {
        let count = { (match: (ItemState) -> Bool) in run.items.filter { match($0.state) }.count }
        let done = count { $0 == .done || $0 == .waitingInInstaller }
        let refused = count { if case .refused = $0 { true } else { false } }
        let already = run.items.filter { $0.state == .alreadyInstalled }.map(\.app.name)
        var parts: [String] = []
        if done > 0 { parts.append("\(done) done") }
        if refused > 0 { parts.append("\(refused) refused") }
        var line = parts.joined(separator: " · ")
        if already.isEmpty { return line.isEmpty ? "You can keep using your Mac." : line + "." }
        let sentence = already.count == 1 ? "\(already[0]) is already on this Mac." : "\(RunText.apps(already.count)) are already on this Mac."
        line = line.isEmpty ? sentence : line + " · " + sentence
        return line + " You can keep using your Mac."
    }
}

struct BarProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        Capsule().fill(Color.SI.rowHover)
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule().fill(Color.SI.accent)
                        .frame(width: proxy.size.width * (configuration.fractionCompleted ?? 0))
                        .animation(.easeOut(duration: 0.3), value: configuration.fractionCompleted)
                }
            }
    }
}

enum RowStyle {
    case running
    case finished
    case finishedPlain
    case nothing
}

struct RunList: View {
    let items: [RunItem]
    let style: RowStyle

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                RunRow(item: item, style: style)
                if item.id != items.last?.id {
                    Divider().overlay(SeparatorStyle()).padding(.horizontal, SISpace.s2)
                }
            }
        }
    }
}

struct RunRow: View {
    let item: RunItem
    let style: RowStyle

    var body: some View {
        HStack(spacing: SISpace.s3) {
            HStack(spacing: SISpace.s3) {
                AppTile(name: item.app.name, token: item.app.token)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.app.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.SI.textPrimary)
                    if let detail {
                        Text(detail)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.SI.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if case .downloading(let fraction?) = item.state, style == .running {
                        ProgressView(value: fraction)
                            .progressViewStyle(BarProgressStyle())
                            .frame(width: 220)
                            .padding(.top, SISpace.s1)
                    }
                }
                Spacer(minLength: SISpace.s2)
            }
            .opacity(dimmed ? 0.65 : 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.app.name)
            .accessibilityValue(spoken)
            trailing
        }
        .padding(.horizontal, SISpace.s2)
        .padding(.vertical, SISpace.s2)
        .frame(minHeight: 64)
        .background(RoundedRectangle(cornerRadius: SIRadius.row).fill(tint))
    }

    private var dimmed: Bool { item.state == .alreadyInstalled || item.state == .cancelled }

    private var tint: Color {
        switch item.state {
        case .verifying: Color.SI.accentTint
        case .waitingInInstaller, .opening: Color.SI.warningTint
        case .refused: style == .finishedPlain ? .clear : Color.SI.dangerTint
        default: .clear
        }
    }

    private var finished: Bool { style == .finished || style == .finishedPlain }

    private var detail: String? {
        switch item.state {
        case .waiting: style == .running ? "Waiting" : nil
        case .downloading(let fraction?): "Downloading · \(Int(fraction * 100))%"
        case .downloading(nil): "Downloading"
        case .verifying: "Checking signature and notarization"
        case .installing: "Installing in Applications"
        case .done: finished ? nil : "Installed in Applications"
        case .refused(let reason): RunText.refusal(reason, short: finished)
        case .opening: "Opening in Apple’s Installer"
        case .waitingInInstaller:
            finished ? "SettleIn opened its installer. It can’t tell if you finished." : "Finish the steps in Apple’s Installer, then come back"
        case .alreadyInstalled:
            switch style {
            case .running: "Already on this Mac. Left as is."
            case .finished, .finishedPlain: "Left as is"
            case .nothing: "Already on this Mac"
            }
        case .cancelled: finished ? "Cancelled" : "Cancelled. Not installed."
        }
    }

    private var spoken: String {
        let status: String
        switch item.state {
        case .downloading(let fraction?): status = "Downloading, \(Int(fraction * 100)) percent"
        case .waitingInInstaller: status = "Waiting in Apple’s Installer"
        case .alreadyInstalled, .cancelled: status = "Skipped"
        default: status = word
        }
        guard let detail else { return status }
        return item.state == .done || status == detail ? status : "\(status). \(detail)"
    }

    private var word: String {
        switch item.state {
        case .waiting: "Waiting"
        case .downloading: "Downloading"
        case .verifying: "Verifying"
        case .installing: "Installing"
        case .done: "Done"
        case .refused: "Refused"
        case .opening: "Opening"
        case .waitingInInstaller: "Show Installer"
        case .alreadyInstalled, .cancelled: "Skipped"
        }
    }

    private var symbol: String {
        switch item.state {
        case .waiting: "clock"
        case .downloading: "arrow.down.to.line"
        case .verifying: "checkmark.shield"
        case .installing: "arrow.down.app"
        case .done: "checkmark.circle"
        case .refused: "xmark.circle"
        case .opening: "arrow.up.forward.app"
        case .waitingInInstaller: "arrow.up.forward.app"
        case .alreadyInstalled, .cancelled: "minus.circle"
        }
    }

    private var colour: Color {
        switch item.state {
        case .done: Color.SI.success
        case .refused: Color.SI.danger
        case .verifying, .installing: Color.SI.accentText
        case .opening: Color.SI.warning
        default: Color.SI.textSecondary
        }
    }

    @ViewBuilder
    private var trailing: some View {
        if item.state == .waitingInInstaller {
            Button("Show Installer", action: showInstaller)
                .buttonStyle(SecondaryButtonStyle())
                .focusRing()
        } else {
            HStack(spacing: 6) {
                Image(systemName: symbol).font(.system(size: 14, weight: .regular))
                Text(word).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(colour)
            .accessibilityHidden(true)
        }
    }
}

struct NothingToInstallView: View {
    let run: InstallRun
    let model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SISpace.s4) {
                ScreenHeading(
                    title: "Nothing to install",
                    detail: "Every app in this link is already on this Mac, so SettleIn left them as they are."
                )
                RunList(items: run.items, style: .nothing)
            }
            .padding(.horizontal, SISpace.s6)
            .padding(.top, SISpace.s5)
            .padding(.bottom, SISpace.s5)
        }
        .safeAreaInset(edge: .bottom) {
            GlassBar {
                Text("Want something else?").font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary)
                Spacer()
                Button("Pick other apps") { model.openPick() }.buttonStyle(SecondaryButtonStyle()).focusRing()
                Button("Close") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(PrimaryButtonStyle()).focusRing()
                    .keyboardShortcut(.defaultAction)
            }
        }
        .onAppear { announce("Nothing to install. Every app in this link is already on this Mac.") }
    }
}

struct FinishedView: View {
    let run: InstallRun
    let model: AppModel

    private func items(_ match: (ItemState) -> Bool) -> [RunItem] { run.items.filter { match($0.state) } }

    private var installed: [RunItem] { items { $0 == .done } }
    private var waiting: [RunItem] { items { $0 == .waitingInInstaller } }
    private var already: [RunItem] { items { $0 == .alreadyInstalled } }
    private var cancelled: [RunItem] { items { $0 == .cancelled } }
    private var refused: [RunItem] { items { if case .refused = $0 { true } else { false } } }

    private var onlyInstalled: Bool { !installed.isEmpty && waiting.isEmpty && already.isEmpty && cancelled.isEmpty && refused.isEmpty }
    private var onlyRefused: Bool { installed.isEmpty && waiting.isEmpty && !refused.isEmpty }
    private var allRefused: Bool { onlyRefused && already.isEmpty && cancelled.isEmpty }

    private var title: String {
        if !installed.isEmpty {
            if onlyInstalled && installed.count > 1 { return "All \(installed.count) apps installed" }
            return "\(RunText.apps(installed.count)) installed"
        }
        if !waiting.isEmpty { return "\(RunText.apps(waiting.count)) opened in Apple’s Installer" }
        return "Nothing was installed"
    }

    private var subtitle: String {
        if allRefused { return "All \(refused.count) \(refused.count == 1 ? "app was" : "apps were") refused. Your Mac is unchanged." }
        var parts: [String] = []
        if !installed.isEmpty && !waiting.isEmpty { parts.append("\(waiting.count) to check in Apple’s Installer") }
        if !already.isEmpty { parts.append("\(already.count) skipped") }
        if !refused.isEmpty { parts.append("\(refused.count) refused") }
        if !cancelled.isEmpty { parts.append("\(cancelled.count) cancelled") }
        return parts.joined(separator: " · ")
    }

    private var summary: String {
        let names = RunText.names(installed.map(\.app.name))
        return "\(names) \(installed.count == 1 ? "is" : "are") in Applications. Each runs macOS’s own check the first time you open it."
    }

    private var barText: String {
        if onlyInstalled { return "You can remove any of them later from SettleIn." }
        if onlyRefused { return "This usually clears up when the developer fixes their download." }
        return "Each app runs macOS’s own check the first time you open it."
    }

    var body: some View {
        content
            .safeAreaInset(edge: .bottom) {
                GlassBar {
                    Text(barText).font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary).lineLimit(1).minimumScaleFactor(0.85)
                    Spacer()
                    if onlyRefused {
                        Button {
                            if let url = URL(string: "https://github.com/asarelcastellanos/settlein.dev/issues") { NSWorkspace.shared.open(url) }
                        } label: {
                            HStack(spacing: 6) { Text("Report a problem"); Image(systemName: "arrow.up.right.square") }
                        }
                        .buttonStyle(SecondaryButtonStyle()).focusRing()
                    } else {
                        Button("Show installed apps") { model.openInstalled() }.buttonStyle(SecondaryButtonStyle()).focusRing()
                    }
                    Button("Done") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(PrimaryButtonStyle()).focusRing()
                        .keyboardShortcut(.defaultAction)
                }
            }
            .onAppear { announce(title) }
    }

    @ViewBuilder
    private var content: some View {
        if onlyInstalled {
            VStack(spacing: SISpace.s3) {
                AnimatedIcon(size: 120)
                Text(title)
                    .font(.system(size: 26, weight: .bold)).tracking(-0.52)
                    .foregroundStyle(Color.SI.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(summary)
                    .font(.system(size: 15)).foregroundStyle(Color.SI.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                recordError
            }
            .padding(SISpace.s5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: SISpace.s4) {
                    HStack(spacing: SISpace.s3) {
                        if !installed.isEmpty || !waiting.isEmpty { AnimatedIcon(size: 58) }
                        ScreenHeading(title: title, detail: subtitle)
                    }
                    recordError
                    group("Installed", installed)
                    group("Check in Apple’s Installer", waiting)
                    group("Already on this Mac", already)
                    group("Not installed", cancelled)
                    group(allRefused ? nil : "Refused", refused)
                }
                .padding(.horizontal, SISpace.s6)
                .padding(.top, SISpace.s5)
                .padding(.bottom, SISpace.s5)
            }
        }
    }

    @ViewBuilder
    private var recordError: some View {
        if run.recordFailed {
            Text("SettleIn couldn’t save its record of these apps. They won’t be listed under Installed by SettleIn. Make sure SettleIn’s folder can be written to.")
                .font(.system(size: 13))
                .foregroundStyle(Color.SI.warning)
                .frame(maxWidth: 560, alignment: .leading)
        }
    }

    @ViewBuilder
    private func group(_ title: String?, _ rows: [RunItem]) -> some View {
        if !rows.isEmpty {
            VStack(alignment: .leading, spacing: SISpace.s1) {
                if let title {
                    Text("\(title.uppercased()) · \(rows.count)")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.SI.textSecondary)
                        .accessibilityAddTraits(.isHeader)
                    Divider().overlay(SeparatorStyle())
                }
                RunList(items: rows, style: title == nil ? .finishedPlain : .finished)
            }
            .padding(.top, SISpace.s1)
        }
    }
}

struct RunPanelContent: View {
    let model: AppModel

    private var run: InstallRun? {
        if case .installing(let run) = model.screen { return run }
        return nil
    }

    private var current: String {
        run?.items.first { $0.state.isActive }?.app.name ?? "The app in progress"
    }

    private var waitingCount: Int { run?.items.filter { $0.state == .waiting }.count ?? 0 }

    var body: some View {
        switch model.panel {
        case .cancel: cancelPanel
        case .change: changePanel
        case nil: EmptyView()
        }
    }

    private var cancelPanel: some View {
        let waiting = waitingCount == 0
            ? ""
            : " The \(RunText.apps(waitingCount)) still waiting won’t be downloaded."
        return VStack(alignment: .leading, spacing: SISpace.s3) {
            heading("Cancel the rest?")
            Text("\(current) finishes installing, so nothing is left half-installed.\(waiting) Apps already installed stay.")
                .font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary)
            buttons {
                Button("Keep installing") { model.panel = nil }
                    .buttonStyle(SecondaryButtonStyle()).focusRing().panelControl(.cancel)
                Button("Cancel the rest") { model.confirm(.cancel) }
                    .buttonStyle(PrimaryButtonStyle()).focusRing().panelControl(.first)
            }
        }
    }

    private var changePanel: some View {
        VStack(alignment: .leading, spacing: SISpace.s3) {
            heading("Change your selection?")
            Text("SettleIn finishes \(current) and stops there. Then Pick apps opens with your list ticked, so you can add or remove apps and install again.")
                .font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary)
            buttons {
                Button("Keep installing") { model.panel = nil }
                    .buttonStyle(SecondaryButtonStyle()).focusRing().panelControl(.cancel)
                Button("Change selection") { model.confirm(.change) }
                    .buttonStyle(PrimaryButtonStyle()).focusRing().panelControl(.first)
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color.SI.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    private func buttons<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: SISpace.s2) {
            Spacer()
            content()
        }
        .padding(.top, SISpace.s2)
    }
}
