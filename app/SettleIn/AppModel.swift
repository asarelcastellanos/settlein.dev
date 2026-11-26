import Foundation
import Observation

enum Destination: Equatable {
    case pick
    case installed
    case installing
}

enum UnreachableKind: Equatable {
    case offline
    case siteError
    case retrying
}

struct InstalledRow: Identifiable, Equatable {
    let app: CatalogApp
    let date: Date

    var id: String { app.id }
}

enum InstalledContent: Equatable {
    case rows([InstalledRow])
    case empty
    case unreadable
}

enum Screen {
    case loading(Destination)
    case unreachable(UnreachableKind)
    case pick(PickSelection)
    case installed(InstalledContent)
    case installing(InstallRun)
}

enum Goal {
    case launch
    case pick([String])
    case installed
}

@Observable
final class PickSelection {
    let groups: [(category: String, apps: [CatalogApp])]
    let installed: Set<String>
    var ticked: Set<String>

    init(catalog: [CatalogApp], ticked: [String]) {
        var order: [String] = []
        for app in catalog where !order.contains(app.category) { order.append(app.category) }
        groups = order.map { category in (category, catalog.filter { $0.category == category }) }
        installed = Set(catalog.filter { Installed.isInstalled($0) }.map(\.token))
        self.ticked = Set(ticked).subtracting(installed)
    }

    var tickedApps: [CatalogApp] {
        groups.flatMap(\.apps).filter { ticked.contains($0.token) }
    }

    func isInstalled(_ app: CatalogApp) -> Bool { installed.contains(app.token) }

    func toggle(_ app: CatalogApp) {
        guard !isInstalled(app) else { return }
        if ticked.contains(app.token) { ticked.remove(app.token) } else { ticked.insert(app.token) }
    }

    private func available(_ apps: [CatalogApp]) -> [CatalogApp] { apps.filter { !isInstalled($0) } }

    func isOn(category apps: [CatalogApp]) -> Bool {
        let rest = available(apps)
        return !rest.isEmpty && rest.allSatisfy { ticked.contains($0.token) }
    }

    func toggle(category apps: [CatalogApp]) {
        let tokens = available(apps).map(\.token)
        if isOn(category: apps) { ticked.subtract(tokens) } else { ticked.formUnion(tokens) }
    }

    func selectAll() {
        ticked = Set(groups.flatMap(\.apps).filter { !isInstalled($0) }.map(\.token))
    }

    func deselectAll() { ticked = [] }
}

@MainActor
@Observable
final class AppModel {
    private(set) var screen: Screen = .loading(.installing)
    private var catalog: [CatalogApp] = []
    private var goal: Goal = .launch
    private(set) var hasRecord = false

    var canNavigate: Bool {
        if case .installing(let run) = screen { return run.finished }
        return true
    }

    func launch() async { await open(.launch) }

    func openPick(ticked: [String] = []) { Task { await open(.pick(ticked)) } }

    func openInstalled() { Task { await open(.installed) } }

    func retry() async {
        screen = .unreachable(.retrying)
        await open(goal)
    }

    func installTicked() {
        guard case .pick(let pick) = screen else { return }
        begin(pick.tickedApps, skipped: [])
    }

    private func open(_ goal: Goal) async {
        self.goal = goal
        let record = InstallRecord.read()
        hasRecord = record != .entries([])
        let tokens: [String]
        if case .launch = goal { tokens = Selection.current() } else { tokens = [] }
        let wanted = Self.destination(goal, hasSelection: !tokens.isEmpty, record: record)
        if wanted == .installed, record == .unreadable {
            screen = .installed(.unreadable)
            return
        }
        if catalog.isEmpty {
            if case .unreachable = screen {} else { screen = .loading(wanted) }
            do {
                catalog = try await CatalogClient.load()
            } catch {
                screen = .unreachable(Self.kind(error))
                return
            }
        }
        let resolved = Selection.resolve(tokens, in: catalog)
        switch Self.destination(goal, hasSelection: !resolved.isEmpty, record: record) {
        case .installing:
            begin(resolved.filter { !Installed.isInstalled($0) }, skipped: resolved.filter { Installed.isInstalled($0) })
        case .pick:
            var preset: [String] = []
            if case .pick(let list) = goal { preset = list }
            screen = .pick(PickSelection(catalog: catalog, ticked: preset))
        case .installed:
            if record == .unreadable { screen = .installed(.unreadable) } else { screen = .installed(content(record)) }
        }
    }

    private func begin(_ toInstall: [CatalogApp], skipped: [CatalogApp]) {
        let run = InstallRun(toInstall: toInstall, skipped: skipped)
        screen = .installing(run)
        Task {
            await run.start()
            InstallRecord.add(run.items.filter { $0.state == .done || $0.state == .waitingInInstaller }.map(\.app))
        }
    }

    private func content(_ record: RecordRead) -> InstalledContent {
        guard case .entries(let entries) = record else { return .unreadable }
        let rows = entries.compactMap { entry -> InstalledRow? in
            guard let app = catalog.first(where: { $0.token == entry.token }), Installed.isInstalled(app) else { return nil }
            return InstalledRow(app: app, date: entry.date)
        }
        return rows.isEmpty ? .empty : .rows(rows)
    }

    static func destination(_ goal: Goal, hasSelection: Bool, record: RecordRead) -> Destination {
        switch goal {
        case .pick: return .pick
        case .installed: return .installed
        case .launch:
            if hasSelection { return .installing }
            return record == .entries([]) ? .pick : .installed
        }
    }

    static func kind(_ error: Error) -> UnreachableKind {
        guard let error = error as? URLError else { return .siteError }
        let offline: Set<URLError.Code> = [
            .notConnectedToInternet, .networkConnectionLost, .dnsLookupFailed,
            .cannotFindHost, .dataNotAllowed, .internationalRoamingOff,
        ]
        return offline.contains(error.code) ? .offline : .siteError
    }
}
