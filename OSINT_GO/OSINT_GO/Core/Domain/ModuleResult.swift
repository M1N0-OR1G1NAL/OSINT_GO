//
//  ModuleResult.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct ModuleResult: Codable, Identifiable {
    let id = UUID()
    let moduleName: String
    let targetId: UUID
    let summary: String
    let details: [String: Any]
    let riskScore: Double
    let timestamp: Date
}
