import Foundation
import Observation

struct Row: Identifiable, Equatable {
    let app: CatalogApp
    let installed: Bool

    var id: String { app.id }
}

enum Screen: Equatable {
    case loading
    case unreachable(String)
    case nothingSelected
    case confirm([Row])
    case allInstalled
    case approved(toInstall: [CatalogApp], skipped: [CatalogApp])
}

@MainActor
@Observable
final class AppModel {
    private(set) var screen: Screen = .loading

    func load() async {
        screen = .loading
        do {
            let catalog = try await CatalogClient.load()
            show(Selection.resolve(Selection.current(), in: catalog))
        } catch {
            screen = .unreachable(Self.reason(error))
        }
    }

    func approve() {
        guard case .confirm(let rows) = screen else { return }
        screen = .approved(
            toInstall: rows.filter { !$0.installed }.map(\.app),
            skipped: rows.filter(\.installed).map(\.app)
        )
    }

    private func show(_ chosen: [CatalogApp]) {
        let rows = chosen.map { Row(app: $0, installed: Installed.isInstalled($0)) }
        if rows.isEmpty {
            screen = .nothingSelected
        } else if rows.allSatisfy(\.installed) {
            screen = .allInstalled
        } else {
            screen = .confirm(rows)
        }
    }

    private static func reason(_ error: Error) -> String {
        if let error = error as? CatalogError { return "The catalog from settlein.dev was refused. \(error.reason)." }
        return "Settlein could not read the catalog from settlein.dev. Check your connection and try again."
    }
}
