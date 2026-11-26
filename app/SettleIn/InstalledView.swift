import AppKit
import SwiftUI

struct InstalledView: View {
    let content: InstalledContent
    let addApps: () -> Void
    let retry: () -> Void

    var body: some View {
        switch content {
        case .rows(let rows): list(rows)
        case .empty: empty
        case .unreadable: unreadable
        }
    }

    private func list(_ rows: [InstalledRow]) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: SISpace.s4) {
                    ScreenHeading(
                        title: "Installed by SettleIn",
                        detail: "Only apps SettleIn installed are listed. Uninstalling removes the app and its leftovers."
                    )
                    VStack(spacing: 0) {
                        ForEach(rows) { row in
                            InstalledRowView(row: row)
                            if row.id != rows.last?.id { Divider().overlay(SeparatorStyle()) }
                        }
                    }
                }
                .padding(.horizontal, SISpace.s6)
                .padding(.top, SISpace.s5)
                .padding(.bottom, SISpace.s5)
            }
            GlassBar {
                Text("\(rows.count) \(rows.count == 1 ? "app" : "apps")")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.SI.textSecondary)
                Spacer()
                Button("Add apps", action: addApps).buttonStyle(PrimaryButtonStyle()).focusRing()
            }
        }
    }

    private var empty: some View {
        CentredMessage(
            title: "Nothing installed yet",
            detail: "Pick the apps you want and SettleIn installs them for you."
        ) {
            AnimatedIcon(size: 122, animated: false)
        } buttons: {
            Button("Pick apps", action: addApps).buttonStyle(PrimaryButtonStyle()).focusRing().keyboardShortcut(.defaultAction)
        }
    }

    private var unreadable: some View {
        CentredMessage(
            title: "Can’t read the list of installed apps",
            detail: "SettleIn’s record of what it installed is missing or damaged. Your apps are still installed."
        ) {
            Text("!")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.SI.warning)
                .frame(width: 88, height: 88)
                .background(Circle().fill(Color.SI.warningTint))
                .accessibilityHidden(true)
        } buttons: {
            Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([InstallRecord.folder]) }
                .buttonStyle(SecondaryButtonStyle()).focusRing()
            Button("Try again", action: retry).buttonStyle(PrimaryButtonStyle()).focusRing().keyboardShortcut(.defaultAction)
        }
    }
}

struct InstalledRowView: View {
    let row: InstalledRow

    private var isPkg: Bool { row.app.installerType == .pkg }

    var body: some View {
        HStack(spacing: SISpace.s3) {
            AppTile(name: row.app.name, token: row.app.token)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.app.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.SI.textPrimary)
                Text(isPkg ? "Removing asks for your admin password" : "Installed \(row.date.formatted(.dateTime.day().month(.abbreviated).year()))")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.SI.textSecondary)
            }
            Spacer()
            if isPkg {
                Image(systemName: "lock")
                    .foregroundStyle(Color.SI.textSecondary)
                    .accessibilityLabel("Removing asks for your admin password")
            }
            Button("Uninstall") {}
                .buttonStyle(SecondaryButtonStyle()).focusRing()
                .disabled(true)
        }
        .frame(height: 68)
        .accessibilityElement(children: .combine)
    }
}
