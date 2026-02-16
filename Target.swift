// Path: AtlasOSINT/Core/Domain/Target.swift

import Foundation

struct Target: Identifiable, Codable, Hashable {
    let id: UUID
    let type: TargetType
    let value: String
    let label: String?
    let createdAt: Date

    init(id: UUID = UUID(),
         type: TargetType,
         value: String,
         label: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.value = value
        self.label = label
        self.createdAt = createdAt
    }
}