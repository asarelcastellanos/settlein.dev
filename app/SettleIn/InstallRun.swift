import Foundation
import Observation

enum ItemState: Equatable {
    case waiting
    case downloading(Double?)
    case verifying
    case installing
    case done
    case refused(String)
    case opening
    case waitingInInstaller

    var isActive: Bool {
        switch self {
        case .downloading, .verifying, .installing, .opening: return true
        default: return false
        }
    }
}

struct RunItem: Identifiable {
    let app: CatalogApp
    var state: ItemState

    var id: String { app.id }
}

@MainActor
@Observable
final class InstallRun {
    private(set) var items: [RunItem]
    let skipped: [CatalogApp]
    let folder: URL
    private(set) var finished = false
    var recordFailed = false

    init(toInstall: [CatalogApp], skipped: [CatalogApp], folder: URL = Installer.destination()) {
        items = toInstall.map { RunItem(app: $0, state: .waiting) }
        self.skipped = skipped
        self.folder = folder
    }

    var settled: Int {
        items.filter { $0.state != .waiting && !$0.state.isActive }.count
    }

    func start() async {
        guard !finished else { return }
        Installer.removeStalePackages()
        for index in items.indices {
            let app = items[index].app
            items[index].state = .downloading(nil)
            do {
                try await Installer.install(app, into: folder) { [weak self] step in
                    Task { @MainActor in self?.update(index, step) }
                }
                items[index].state = app.installerType == .pkg ? .waitingInInstaller : .done
            } catch let refusal as Refusal {
                items[index].state = .refused(refusal.reason)
            } catch {
                items[index].state = .refused("SettleIn could not finish. \(error.localizedDescription)")
            }
        }
        finished = true
    }

    private func update(_ index: Int, _ step: InstallStep) {
        guard items[index].state.isActive else { return }
        switch step {
        case .downloading(let fraction): items[index].state = .downloading(fraction)
        case .verifying: items[index].state = .verifying
        case .installing: items[index].state = .installing
        case .opening: items[index].state = .opening
        }
    }
}
