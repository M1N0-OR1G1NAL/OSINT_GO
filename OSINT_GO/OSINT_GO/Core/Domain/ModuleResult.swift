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
    let details: [String: String]
    let riskScore: Double
    let timestamp: Date

    static func detailString(from value: Any) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        if let convertible = value as? CustomStringConvertible {
            return convertible.description
        }

        return String(describing: value)
    }
}
