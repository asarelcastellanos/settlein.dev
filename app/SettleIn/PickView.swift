import SwiftUI

struct PickView: View {
    let pick: PickSelection
    let back: (() -> Void)?
    let install: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 270, maximum: 420), spacing: SISpace.s6, alignment: .top)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: SISpace.s5) {
                    header
                    LazyVGrid(columns: columns, alignment: .leading, spacing: SISpace.s5) {
                        ForEach(pick.groups, id: \.category) { group in
                            CategorySection(pick: pick, category: group.category, apps: group.apps)
                        }
                    }
                }
                .padding(.horizontal, SISpace.s6)
                .padding(.top, SISpace.s5)
                .padding(.bottom, SISpace.s5)
            }
            PickBar(count: pick.ticked.count, tickedApps: pick.tickedApps, install: install)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: SISpace.s2) {
                if let back {
                    Button(action: back) { Text("‹ Installed apps") }
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.SI.accentText)
                }
                ScreenHeading(title: "Pick apps", detail: "Apps already on this Mac are marked Installed.")
            }
            Spacer()
            Button("Select all") { pick.selectAll() }.buttonStyle(SecondaryButtonStyle())
            Button("Deselect all") { pick.deselectAll() }.buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct CategorySection: View {
    let pick: PickSelection
    let category: String
    let apps: [CatalogApp]

    private var allOn: Bool { pick.isOn(category: apps) }

    var body: some View {
        VStack(alignment: .leading, spacing: SISpace.s1) {
            HStack(spacing: SISpace.s3) {
                Button { pick.toggle(category: apps) } label: {
                    HStack(spacing: SISpace.s3) {
                        SquareCheckbox(isOn: allOn)
                        Text(category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.SI.textPrimary)
                        Spacer()
                        Text(allOn ? "Deselect all" : "Select all")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.SI.accentText)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(allOn ? "Deselect all" : "Select all") in \(category)")
                .accessibilityAddTraits(allOn ? .isSelected : [])
            }
            .padding(.horizontal, SISpace.s2)
            .frame(height: 36)
            ForEach(apps) { app in
                PickRow(app: app, installed: pick.isInstalled(app), isOn: pick.ticked.contains(app.token)) {
                    pick.toggle(app)
                }
            }
        }
    }
}

struct PickRow: View {
    let app: CatalogApp
    let installed: Bool
    let isOn: Bool
    let toggle: () -> Void

    @State private var hovering = false

    var body: some View {
        if installed {
            rowContent
                .accessibilityElement(children: .combine)
                .accessibilityValue("Installed")
        } else {
            Button(action: toggle) { rowContent }
                .buttonStyle(.plain)
                .onHover { hovering = $0 }
                .accessibilityElement(children: .combine)
                .accessibilityValue(isOn ? "Ticked" : "Not ticked")
        }
    }

    private var rowContent: some View {
        HStack(spacing: SISpace.s3) {
            if installed {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.SI.success)
                    .frame(width: 18, height: 18)
            } else {
                SquareCheckbox(isOn: isOn)
            }
            AppTile(name: app.name, token: app.token)
            Text(app.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(installed ? Color.SI.textSecondary : Color.SI.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: SISpace.s2)
            if installed {
                Text("Installed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.SI.success)
            }
        }
        .padding(.horizontal, SISpace.s2)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: SIRadius.row)
                .fill(isOn ? Color.SI.accentTint : (hovering && !installed ? Color.SI.rowHover : .clear))
        )
        .contentShape(Rectangle())
    }
}

struct PickBar: View {
    let count: Int
    let tickedApps: [CatalogApp]
    let install: () -> Void

    var body: some View {
        GlassBar {
            HStack(spacing: SISpace.s2) {
                ForEach(0..<3, id: \.self) { index in
                    if index < tickedApps.count {
                        AppTile(name: tickedApps[index].name, token: tickedApps[index].token, size: 42)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(PlaceholderEdgeStyle(), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            .frame(width: 42, height: 42)
                    }
                }
            }
            .accessibilityHidden(true)
            Text("\(count) \(count == 1 ? "app" : "apps") selected")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(count == 0 ? Color.SI.textSecondary : Color.SI.textPrimary)
                .accessibilityLabel(count == 0 ? "0 apps selected. Tick apps to install them" : "\(count) \(count == 1 ? "app" : "apps") selected")
            Spacer()
            if count == 0 {
                Text("Tick apps to install them")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.SI.textSecondary)
                    .accessibilityHidden(true)
            } else {
                Button(action: install) { Text("Install \(count) \(count == 1 ? "app" : "apps")") }
                    .buttonStyle(PrimaryButtonStyle())
                    .keyboardShortcut(.defaultAction)
            }
        }
    }
}

struct LoadingShell<Content: View>: View {
    @State private var visible = false
    @ViewBuilder let content: Content

    var body: some View {
        Group {
            if visible { content } else { Color.clear }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(300))
            visible = true
        }
    }
}

struct PickLoadingView: View {
    private let widths: [[CGFloat]] = [[0.5, 0.7, 0.42], [0.55, 0.75, 0.42, 0.6], [0.5, 0.7, 0.4, 0.62]]

    var body: some View {
        LoadingShell {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: SISpace.s5) {
                    VStack(alignment: .leading, spacing: SISpace.s1) {
                        ScreenHeading(title: "Pick apps", detail: nil)
                        HStack(spacing: SISpace.s2) {
                            ProgressView().controlSize(.small)
                            Text("Loading the catalog from settlein.dev…")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.SI.textSecondary)
                        }
                    }
                    HStack(alignment: .top, spacing: SISpace.s6) {
                        ForEach(0..<3, id: \.self) { column in
                            VStack(alignment: .leading, spacing: SISpace.s1) {
                                Capsule().fill(Color.SI.rowHover).frame(width: 110, height: 10).frame(height: 36)
                                ForEach(widths[column].indices, id: \.self) { row in
                                    HStack(spacing: SISpace.s3) {
                                        RoundedRectangle(cornerRadius: SIRadius.checkbox).fill(Color.white)
                                            .overlay(RoundedRectangle(cornerRadius: SIRadius.checkbox).stroke(SeparatorStyle()))
                                            .frame(width: 18, height: 18)
                                        RoundedRectangle(cornerRadius: 8).fill(Color.SI.iconPlaceholder).frame(width: 34, height: 34)
                                        Capsule().fill(Color.SI.rowHover).frame(width: 150 * widths[column][row], height: 8)
                                        Spacer()
                                    }
                                    .frame(height: 52)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, SISpace.s6)
                .padding(.top, SISpace.s5)
                Spacer()
                GlassBar {
                    HStack(spacing: SISpace.s2) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(PlaceholderEdgeStyle(), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                .frame(width: 42, height: 42)
                        }
                    }
                    Text("Your choices appear here").font(.system(size: 14)).foregroundStyle(Color.SI.textSecondary)
                    Spacer()
                }
            }
        }
    }
}
