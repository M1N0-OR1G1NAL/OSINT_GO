//
//  Investigation.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftData

@Model
class Investigation {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var targets: [Target] = []
    var notes: [Note] = []
    var roots: String = "" // Origins/roots of investigation
    var graphData: GraphData?
    var riskScore: Double = 0.0
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
