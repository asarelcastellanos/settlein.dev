import SwiftUI

extension Color {
    enum SI {
        static let groundBase = Color(.sRGB, red: 0.933, green: 0.945, blue: 0.973, opacity: 1.00)
        static let groundGlowBlue = Color(.sRGB, red: 0.431, green: 0.549, blue: 1.000, opacity: 0.38)
        static let groundGlowViolet = Color(.sRGB, red: 0.725, green: 0.510, blue: 1.000, opacity: 0.30)
        static let groundGlowCyan = Color(.sRGB, red: 0.314, green: 0.784, blue: 0.902, opacity: 0.22)
        static let surfacePanel = Color(.sRGB, red: 1.000, green: 1.000, blue: 1.000, opacity: 0.72)
        static let surfaceWindow = Color(.sRGB, red: 1.000, green: 1.000, blue: 1.000, opacity: 0.85)
        static let surfaceSide = Color(.sRGB, red: 0.945, green: 0.953, blue: 0.980, opacity: 1.00)
        static let rowHover = Color(.sRGB, red: 0.902, green: 0.918, blue: 0.961, opacity: 1.00)
        static let separator = Color(.sRGB, red: 0.863, green: 0.882, blue: 0.933, opacity: 1.00)
        static let textPrimary = Color(.sRGB, red: 0.102, green: 0.114, blue: 0.169, opacity: 1.00)
        static let textSecondary = Color(.sRGB, red: 0.329, green: 0.353, blue: 0.431, opacity: 1.00)
        static let accent = Color(.sRGB, red: 0.227, green: 0.357, blue: 0.937, opacity: 1.00)
        static let accentHi = Color(.sRGB, red: 0.373, green: 0.490, blue: 1.000, opacity: 1.00)
        static let accentText = Color(.sRGB, red: 0.188, green: 0.282, blue: 0.839, opacity: 1.00)
        static let accentTint = Color(.sRGB, red: 0.890, green: 0.910, blue: 1.000, opacity: 1.00)
        static let focusRing = Color(.sRGB, red: 0.227, green: 0.357, blue: 0.937, opacity: 1.00)
        static let checkboxEdge = Color(.sRGB, red: 0.494, green: 0.525, blue: 0.620, opacity: 1.00)
        static let iconPlaceholder = Color(.sRGB, red: 0.882, green: 0.898, blue: 0.945, opacity: 1.00)
        static let success = Color(.sRGB, red: 0.102, green: 0.498, blue: 0.216, opacity: 1.00)
        static let warning = Color(.sRGB, red: 0.541, green: 0.353, blue: 0.000, opacity: 1.00)
        static let warningTint = Color(.sRGB, red: 1.000, green: 0.957, blue: 0.863, opacity: 1.00)
        static let danger = Color(.sRGB, red: 0.769, green: 0.086, blue: 0.110, opacity: 1.00)
        static let dangerTint = Color(.sRGB, red: 0.992, green: 0.910, blue: 0.910, opacity: 1.00)
        static let destructive = Color(.sRGB, red: 0.851, green: 0.176, blue: 0.176, opacity: 1.00)
        static let disabled = Color(.sRGB, red: 0.863, green: 0.882, blue: 0.933, opacity: 1.00)
        static let disabledText = Color(.sRGB, red: 0.494, green: 0.518, blue: 0.600, opacity: 1.00)
    }
}

enum SISpace {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 24
    static let s6: CGFloat = 32
    static let s7: CGFloat = 48
    static let s8: CGFloat = 64
    static let s9: CGFloat = 96
}

enum SIRadius {
    static let checkbox: CGFloat = 5
    static let row: CGFloat = 9
    static let button: CGFloat = 10
    static let panel: CGFloat = 18
    static let window: CGFloat = 14
}
