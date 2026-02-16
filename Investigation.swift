// Path: AtlasOSINT/Core/Domain/Investigation.swift

import Foundation

struct Investigation: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var targets: [Target]
    var results: [UUID: [ModuleResult]]   // klíč = Target.id
    var isStarred: Bool

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        targets: [Target] = [],
        results: [UUID: [ModuleResult]] = [:],
        isStarred: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.targets = targets
        self.results = results
        self.isStarred = isStarred
    }

    func updatingUpdatedAt() -> Investigation {
        var copy = self
        copy.updatedAt = Date()
        return copy
    }
}