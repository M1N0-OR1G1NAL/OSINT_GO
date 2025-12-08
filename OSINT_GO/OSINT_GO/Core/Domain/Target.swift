//
//  Target.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftData

@Model
class Target {
    @Attribute(.unique) var id: UUID
    var type: String
    var value: String
    var label: String
    var investigation: Investigation?
    var results: [ModuleResult] = []
    
    init(id: UUID = UUID(), type: TargetType, value: String, label: String = "") {
        self.id = id
        self.type = type.rawValue
        self.value = value
        self.label = label
    }
}
