import SwiftUI

enum PanelControl: Hashable {
    case first
    case cancel
}

private struct PanelFocusKey: EnvironmentKey {
    static let defaultValue: FocusState<PanelControl?>.Binding? = nil
}

private struct PanelDestructiveKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    fileprivate var panelFocus: FocusState<PanelControl?>.Binding? {
        get { self[PanelFocusKey.self] }
        set { self[PanelFocusKey.self] = newValue }
    }

    fileprivate var panelDestructive: Bool {
        get { self[PanelDestructiveKey.self] }
        set { self[PanelDestructiveKey.self] = newValue }
    }
}

private struct PanelControlModifier: ViewModifier {
    let role: PanelControl
    @Environment(\.panelFocus) private var focus
    @Environment(\.panelDestructive) private var destructive

    func body(content: Content) -> some View {
        if let focus {
            if role == .cancel && destructive {
                content.focused(focus, equals: role).keyboardShortcut(.defaultAction)
            } else {
                content.focused(focus, equals: role)
            }
        } else {
            content
        }
    }
}

extension View {
    func panelControl(_ role: PanelControl) -> some View {
        modifier(PanelControlModifier(role: role))
    }
}

struct CentredPanel<Content: View>: View {
    let destructive: Bool
    let cancel: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focus: PanelControl?

    var body: some View {
        ZStack {
            Color(.sRGB, red: 10 / 255, green: 15 / 255, blue: 40 / 255, opacity: 0.22)
                .onTapGesture {}
            VStack(alignment: .leading, spacing: SISpace.s3) { content }
                .padding(SISpace.s5)
                .frame(width: 380)
                .background(RoundedRectangle(cornerRadius: SIRadius.panel).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: SIRadius.panel).stroke(SeparatorStyle(), lineWidth: 1))
                .shadow(color: Color(.sRGB, red: 10 / 255, green: 15 / 255, blue: 40 / 255, opacity: 0.30), radius: 30, y: 24)
                .accessibilityAddTraits(.isModal)
                .environment(\.panelFocus, $focus)
                .environment(\.panelDestructive, destructive)
                .background(
                    Button("", action: cancel)
                        .keyboardShortcut(.cancelAction)
                        .opacity(0)
                        .focusable(false)
                        .accessibilityHidden(true)
                )
        }
        .onAppear { focus = destructive ? .cancel : .first }
        .transition(.opacity.animation(.easeOut(duration: reduceMotion ? 0.12 : 0.2)))
    }
}

extension View {
    func centredPanel<ID: Hashable, Panel: View>(
        isPresented: Binding<Bool>,
        opener: FocusState<ID?>.Binding,
        openerID: ID,
        destructive: Bool = false,
        @ViewBuilder content: @escaping () -> Panel
    ) -> some View {
        disabled(isPresented.wrappedValue)
        .overlay {
            if isPresented.wrappedValue {
                CentredPanel(destructive: destructive, cancel: { isPresented.wrappedValue = false }, content: content)
            }
        }
        .animation(.easeOut(duration: 0.12), value: isPresented.wrappedValue)
        .onChange(of: isPresented.wrappedValue) { _, shown in
            if !shown { opener.wrappedValue = openerID }
        }
    }
}
