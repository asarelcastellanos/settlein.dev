import AppKit
import SwiftUI

struct UnreachableView: View {
    let kind: UnreachableKind
    let retry: () -> Void

    var body: some View {
        CentredMessage(title: title, detail: detail) {
            if kind == .retrying {
                ProgressView()
                    .controlSize(.large)
                    .frame(width: 88, height: 88)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color.SI.surfaceSide))
            } else {
                StatusBadge(symbol: "icloud.slash", tint: Color.SI.textSecondary, background: Color.SI.surfaceSide)
            }
        } buttons: {
            Button("Close") { NSApplication.shared.terminate(nil) }.buttonStyle(SecondaryButtonStyle()).focusRing()
            Button("Try again", action: retry).buttonStyle(PrimaryButtonStyle()).focusRing().keyboardShortcut(.defaultAction)
                .disabled(kind == .retrying)
        }
    }

    private var title: String {
        switch kind {
        case .offline: "Can’t reach the catalog"
        case .siteError: "The catalog didn’t load"
        case .retrying: "Trying again…"
        }
    }

    private var detail: String {
        switch kind {
        case .offline: "This Mac seems to be offline. Check your Wi-Fi or network, then try again."
        case .siteError: "settlein.dev answered with an error. Try again in a few minutes."
        case .retrying: "Checking settlein.dev."
        }
    }
}
