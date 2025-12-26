// Path: AtlasOSINT/Core/Domain/ModuleResult.swift

import Foundation

enum ModuleResult: Hashable {
    case textSummary(String)
    case keyValue([String: String])
    case graph(GraphData)
    case riskScore(Double, reason: String)
    case deviceSecurity(DeviceSecurityReport)
}

extension ModuleResult: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case dict
        case graph
        case score
        case reason
        case deviceSecurity
    }

    private enum ResultType: String, Codable {
        case textSummary
        case keyValue
        case graph
        case riskScore
        case deviceSecurity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ResultType.self, forKey: .type)

        switch type {
        case .textSummary:
            let text = try container.decode(String.self, forKey: .text)
            self = .textSummary(text)
        case .keyValue:
            let dict = try container.decode([String: String].self, forKey: .dict)
            self = .keyValue(dict)
        case .graph:
            let graph = try container.decode(GraphData.self, forKey: .graph)
            self = .graph(graph)
        case .riskScore:
            let score = try container.decode(Double.self, forKey: .score)
            let reason = try container.decode(String.self, forKey: .reason)
            self = .riskScore(score, reason: reason)
        case .deviceSecurity:
            let report = try container.decode(DeviceSecurityReport.self, forKey: .deviceSecurity)
            self = .deviceSecurity(report)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .textSummary(let text):
            try container.encode(ResultType.textSummary, forKey: .type)
            try container.encode(text, forKey: .text)
        case .keyValue(let dict):
            try container.encode(ResultType.keyValue, forKey: .type)
            try container.encode(dict, forKey: .dict)
        case .graph(let graph):
            try container.encode(ResultType.graph, forKey: .type)
            try container.encode(graph, forKey: .graph)
        case .riskScore(let score, let reason):
            try container.encode(ResultType.riskScore, forKey: .type)
            try container.encode(score, forKey: .score)
            try container.encode(reason, forKey: .reason)
        case .deviceSecurity(let report):
            try container.encode(ResultType.deviceSecurity, forKey: .type)
            try container.encode(report, forKey: .deviceSecurity)
        }
    }
}