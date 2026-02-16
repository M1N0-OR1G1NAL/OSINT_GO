// Path: AtlasOSINT/Utils/RiskScoreFormatter.swift

import Foundation

enum RiskLevel: String {
    case low
    case medium
    case high
}

struct RiskScoreFormatter {
    static func level(for score: Double) -> RiskLevel {
        switch score {
        case ..<0.33:
            return .low
        case ..<0.66:
            return .medium
        default:
            return .high
        }
    }

    static func label(for score: Double) -> String {
        let level = level(for: score)
        switch level {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}