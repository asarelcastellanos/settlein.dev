import SwiftUI

struct CentredPanel<Content: View>: View {
    let cancel: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(.sRGB, red: 10 / 255, green: 15 / 255, blue: 40 / 255, opacity: 0.22)
                .ignoresSafeArea()
                .onTapGesture {}
            VStack(alignment: .leading, spacing: SISpace.s3) { content }
                .padding(SISpace.s5)
                .frame(width: 380)
                .background(RoundedRectangle(cornerRadius: SIRadius.panel).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: SIRadius.panel).stroke(Color.SI.separator, lineWidth: 1))
                .shadow(color: Color(.sRGB, red: 10 / 255, green: 15 / 255, blue: 40 / 255, opacity: 0.30), radius: 30, y: 24)
                .accessibilityAddTraits(.isModal)
                .background(
                    Button("", action: cancel)
                        .keyboardShortcut(.cancelAction)
                        .opacity(0)
                        .accessibilityHidden(true)
                )
        }
        .transition(.opacity.animation(.easeOut(duration: reduceMotion ? 0.12 : 0.2)))
    }
}

extension View {
    func centredPanel<Panel: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Panel
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                CentredPanel(cancel: { isPresented.wrappedValue = false }, content: content)
            }
        }
        .animation(.easeOut(duration: 0.12), value: isPresented.wrappedValue)
    }
}
