import Foundation

enum Selection {
    static func current() -> [String] {
        #if DEBUG
        if let list = UserDefaults.standard.string(forKey: "selection") {
            return list.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        #endif
        return []
    }

    static func resolve(_ names: [String], in catalog: [CatalogApp]) -> [CatalogApp] {
        var chosen: [CatalogApp] = []
        for name in names {
            guard let app = catalog.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }),
                  !chosen.contains(app) else { continue }
            chosen.append(app)
        }
        return chosen
    }
}
