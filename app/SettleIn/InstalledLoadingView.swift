import SwiftUI

struct InstalledLoadingView: View {
    var body: some View {
        LoadingShell {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: SISpace.s4) {
                    ScreenHeading(title: "Installed by SettleIn", detail: nil)
                    HStack(spacing: SISpace.s2) {
                        ProgressView().controlSize(.small)
                        Text("Checking which apps are still on this Mac…")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.SI.textSecondary)
                    }
                    VStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { index in
                            HStack(spacing: SISpace.s3) {
                                RoundedRectangle(cornerRadius: 8).fill(Color.SI.iconPlaceholder).frame(width: 34, height: 34)
                                VStack(alignment: .leading, spacing: SISpace.s2) {
                                    Capsule().fill(Color.SI.rowHover).frame(width: 120 + CGFloat(index % 2) * 40, height: 10)
                                    Capsule().fill(Color.SI.rowHover).frame(width: 80, height: 8)
                                }
                                Spacer()
                            }
                            .frame(height: 68)
                            if index < 3 { Divider().overlay(SeparatorStyle()) }
                        }
                    }
                }
                .padding(.horizontal, SISpace.s6)
                .padding(.top, SISpace.s5)
                Spacer()
                GlassBar {
                    Text("Checking…").font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary)
                    Spacer()
                    Button("Add apps") {}.buttonStyle(PrimaryButtonStyle()).focusRing().disabled(true)
                }
            }
        }
    }
}
