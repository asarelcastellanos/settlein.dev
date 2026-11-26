import SwiftUI

// SettleIn colour tokens. Light only: the app forces .preferredColorScheme(.light).
// Dark values are reserved in tokens.json and are intentionally not here.
extension Color {
    enum SI {
        /// Page base under the glows (website); app window wallpaper in mock-ups
        static let groundBase = Color(.sRGB, red: 0.933, green: 0.945, blue: 0.973, opacity: 1.00)
        /// Radial glow, top left, 900 × 600 px
        static let groundGlowBlue = Color(.sRGB, red: 0.431, green: 0.549, blue: 1.000, opacity: 0.38)
        /// Radial glow, top right, 800 × 600 px
        static let groundGlowViolet = Color(.sRGB, red: 0.725, green: 0.510, blue: 1.000, opacity: 0.30)
        /// Radial glow, bottom, 1000 × 700 px
        static let groundGlowCyan = Color(.sRGB, red: 0.314, green: 0.784, blue: 0.902, opacity: 0.22)
        /// Frosted panels and the address strip (blur 24 px)
        static let surfacePanel = Color(.sRGB, red: 1.000, green: 1.000, blue: 1.000, opacity: 0.72)
        /// Website app window and the Mac app window (blur 30–40 px)
        static let surfaceWindow = Color(.sRGB, red: 1.000, green: 1.000, blue: 1.000, opacity: 0.85)
        /// Side areas, path lists, notes inside panels
        static let surfaceSide = Color(.sRGB, red: 0.945, green: 0.953, blue: 0.980, opacity: 1.00)
        /// Row and button hover, progress track
        static let rowHover = Color(.sRGB, red: 0.902, green: 0.918, blue: 0.961, opacity: 1.00)
        /// Hairlines between rows and sections
        static let separator = Color(.sRGB, red: 0.863, green: 0.882, blue: 0.933, opacity: 1.00)
        /// Headings, app names, body
        static let textPrimary = Color(.sRGB, red: 0.102, green: 0.114, blue: 0.169, opacity: 1.00)
        /// Supporting text, counts, captions (6:1 on base)
        static let textSecondary = Color(.sRGB, red: 0.329, green: 0.353, blue: 0.431, opacity: 1.00)
        /// Primary button fill (with accent-hi gradient), ticked checkbox
        static let accent = Color(.sRGB, red: 0.227, green: 0.357, blue: 0.937, opacity: 1.00)
        /// Top of the primary button gradient
        static let accentHi = Color(.sRGB, red: 0.373, green: 0.490, blue: 1.000, opacity: 1.00)
        /// Links, Select all, eyebrow labels
        static let accentText = Color(.sRGB, red: 0.188, green: 0.282, blue: 0.839, opacity: 1.00)
        /// Ticked row, verifying row, banners
        static let accentTint = Color(.sRGB, red: 0.890, green: 0.910, blue: 1.000, opacity: 1.00)
        /// 3 px keyboard focus outline, 2 px offset
        static let focusRing = Color(.sRGB, red: 0.227, green: 0.357, blue: 0.937, opacity: 1.00)
        /// Square checkbox border at rest. 2.2:1 on white: see ACCESSIBILITY.md, fix A-1
        static let checkboxEdge = Color(.sRGB, red: 0.494, green: 0.525, blue: 0.620, opacity: 1.00)
        /// App icon slot before the real icon loads
        static let iconPlaceholder = Color(.sRGB, red: 0.882, green: 0.898, blue: 0.945, opacity: 1.00)
        /// Done, Installed. Use on window surfaces (5:1 on white), not on the ground (4.49:1)
        static let success = Color(.sRGB, red: 0.102, green: 0.498, blue: 0.216, opacity: 1.00)
        /// Waiting in Apple’s Installer, notices
        static let warning = Color(.sRGB, red: 0.541, green: 0.353, blue: 0.000, opacity: 1.00)
        /// Installer row background
        static let warningTint = Color(.sRGB, red: 1.000, green: 0.957, blue: 0.863, opacity: 1.00)
        /// Refused and its reason
        static let danger = Color(.sRGB, red: 0.769, green: 0.086, blue: 0.110, opacity: 1.00)
        /// Refused row background
        static let dangerTint = Color(.sRGB, red: 0.992, green: 0.910, blue: 0.910, opacity: 1.00)
        /// Uninstall button fill
        static let destructive = Color(.sRGB, red: 0.851, green: 0.176, blue: 0.176, opacity: 1.00)
        /// Disabled button fill / label
        static let disabled = Color(.sRGB, red: 0.863, green: 0.882, blue: 0.933, opacity: 1.00)
        /// Disabled button label
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
