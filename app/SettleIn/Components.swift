import SwiftUI

struct WindowGround: View {
    var body: some View {
        Rectangle().fill(.ultraThinMaterial)
            .overlay(Color.SI.surfaceWindow)
            .ignoresSafeArea()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(enabled ? Color.white : Color.SI.disabledText)
            .padding(.horizontal, SISpace.s4)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: SIRadius.button)
                    .fill(enabled
                        ? AnyShapeStyle(LinearGradient(colors: [Color.SI.accentHi, Color.SI.accent], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.SI.disabled))
            )
            .shadow(color: enabled ? Color.SI.accent.opacity(0.32) : .clear, radius: 9, y: 6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(enabled ? Color.SI.textPrimary : Color.SI.disabledText)
            .padding(.horizontal, SISpace.s4)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: SIRadius.button)
                    .fill(configuration.isPressed ? Color.SI.rowHover : Color.white)
            )
            .overlay(RoundedRectangle(cornerRadius: SIRadius.button).stroke(Color.SI.separator, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct AppTile: View {
    let name: String
    let token: String
    var size: CGFloat = 34
    @State private var icon: NSImage?

    var body: some View {
        Group {
            if let icon {
                Image(nsImage: icon).resizable().scaledToFit()
            } else {
                Text(String(name.prefix(2)))
                    .font(.system(size: size * 0.32, weight: .semibold))
                    .foregroundStyle(Color.SI.textSecondary)
                    .frame(width: size, height: size)
                    .background(RoundedRectangle(cornerRadius: size * 0.2237).fill(Color.SI.iconPlaceholder))
            }
        }
        .frame(width: size, height: size)
        .task(id: token) { icon = await IconLoader.image(token: token) }
        .accessibilityHidden(true)
    }
}

struct SquareCheckbox: View {
    let isOn: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: SIRadius.checkbox)
            .fill(isOn ? Color.SI.accent : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: SIRadius.checkbox)
                    .stroke(isOn ? Color.SI.accent : Color.SI.checkboxEdge, lineWidth: 1.5)
            )
            .overlay {
                if isOn {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
                }
            }
            .frame(width: 18, height: 18)
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.16), value: isOn)
    }
}

struct GlassBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 14) { content }
            .padding(.horizontal, SISpace.s3)
            .frame(height: 64)
            .glassEffect(.regular, in: .rect(cornerRadius: SIRadius.panel))
            .padding(.horizontal, SISpace.s4)
            .padding(.bottom, SISpace.s4)
    }
}

struct ScreenHeading: View {
    let title: String
    let detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SISpace.s1) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .tracking(-0.52)
                .foregroundStyle(Color.SI.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let detail {
                Text(detail).font(.system(size: 15)).foregroundStyle(Color.SI.textSecondary)
            }
        }
    }
}

struct CentredMessage<Icon: View, Buttons: View>: View {
    let title: String
    let detail: String
    @ViewBuilder let icon: Icon
    @ViewBuilder let buttons: Buttons

    var body: some View {
        VStack(spacing: SISpace.s3) {
            icon
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .tracking(-0.52)
                .foregroundStyle(Color.SI.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(detail)
                .font(.system(size: 15))
                .foregroundStyle(Color.SI.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            HStack(spacing: SISpace.s2) { buttons }.padding(.top, SISpace.s2)
        }
        .padding(SISpace.s5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, SISpace.s7)
    }
}

struct StatusBadge: View {
    let symbol: String
    let tint: Color
    let background: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 88, height: 88)
            .background(RoundedRectangle(cornerRadius: 24).fill(background))
            .accessibilityHidden(true)
    }
}
