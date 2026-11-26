import AppKit
import SwiftUI

struct SettleInCommands: Commands {
    let model: AppModel

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About SettleIn") { NSApplication.shared.orderFrontStandardAboutPanel(nil) }
            Divider()
            Button("Check for Updates…") {}.disabled(true)
        }
        CommandGroup(replacing: .systemServices) {}
        CommandGroup(replacing: .appVisibility) {
            Button("Hide SettleIn") { NSApplication.shared.hide(nil) }
                .keyboardShortcut("h")
            Button("Hide Others") { NSApplication.shared.hideOtherApplications(nil) }
                .keyboardShortcut("h", modifiers: [.command, .option])
        }
        CommandGroup(replacing: .toolbar) {}
        CommandGroup(replacing: .sidebar) {}
        CommandMenu("Apps") {
            Button("Pick Apps…") { model.openPick() }
                .keyboardShortcut("n")
                .disabled(!model.canNavigate)
            Button("Installed Apps") { model.openInstalled() }
                .keyboardShortcut("1")
                .disabled(!model.canNavigate)
            Divider()
            Button("Change Selection…") {}
                .keyboardShortcut("e")
                .disabled(true)
            Button("Cancel the Rest…") {}
                .keyboardShortcut(".")
                .disabled(true)
        }
        CommandGroup(replacing: .help) {
            Button("How SettleIn Checks Apps") { open("https://settlein.dev/verify") }
            Button("What SettleIn Sends") { open("https://settlein.dev/privacy") }
            Divider()
            Button("Report a Problem…") { open("https://github.com/asarelcastellanos/settlein.dev/issues") }
            Button("settlein.dev") { open("https://settlein.dev") }
        }
    }

    private func open(_ address: String) {
        if let url = URL(string: address) { NSWorkspace.shared.open(url) }
    }
}
