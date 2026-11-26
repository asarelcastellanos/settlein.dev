import Foundation
import Observation
import SwiftUI

enum ItemState: Equatable {
    case waiting
    case downloading(Double?)
    case verifying
    case installing
    case done
    case refused(String)
    case opening
    case waitingInInstaller
    case alreadyInstalled
    case cancelled

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

enum RunStop {
    case cancel
    case change
}

@MainActor
@Observable
final class InstallRun {
    private(set) var items: [RunItem]
    let folder: URL
    private(set) var finished = false
    private(set) var stop: RunStop?
    var recordFailed = false

    init(apps: [CatalogApp], folder: URL = Installer.destination()) {
        items = apps.map { RunItem(app: $0, state: Installed.isInstalled($0) ? .alreadyInstalled : .waiting) }
        self.folder = folder
    }

    var nothingToInstall: Bool { items.allSatisfy { $0.state == .alreadyInstalled } }

    var retryTokens: [String] {
        items.filter { $0.state != .done && $0.state != .waitingInInstaller }.map(\.app.token)
    }

    func requestStop(_ request: RunStop) {
        guard !finished, stop == nil else { return }
        stop = request
        for index in items.indices where items[index].state == .waiting { items[index].state = .cancelled }
    }

    var settled: Int {
        items.filter { $0.state != .waiting && !$0.state.isActive }.count
    }

    func start() async {
        guard !finished else { return }
        Installer.removeStalePackages()
        for index in items.indices where items[index].state == .waiting {
            let app = items[index].app
            items[index].state = .downloading(nil)
            do {
                try await Installer.install(app, into: folder) { [weak self] step in
                    Task { @MainActor in self?.update(index, step) }
                }
                conclude(index, app.installerType == .pkg ? .waitingInInstaller : .done)
            } catch let refusal as Refusal {
                conclude(index, .refused(refusal.reason))
            } catch {
                conclude(index, .refused("SettleIn could not finish. \(error.localizedDescription)"))
            }
        }
        finished = true
    }

    private func conclude(_ index: Int, _ state: ItemState) {
        items[index].state = state
        let name = items[index].app.name
        switch state {
        case .done: announce("\(name), Done")
        case .refused(let reason): announce("\(name), Refused. \(RunText.refusal(reason, short: false))")
        case .waitingInInstaller: announce("\(name). Finish the steps in Apple’s Installer, then come back")
        default: break
        }
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
