//
//  ExportService.swift
//  OSINT
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI
import SwiftData

class ExportService {
    static let shared = ExportService()
    
    func exportInvestigation(_ investigation: Investigation, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        var exportData: [String: Any] = [
            "name": investigation.name,
            "createdAt": ISO8601DateFormatter().string(from: investigation.createdAt),
            "riskScore": investigation.riskScore,
            "targets": investigation.targets.map { target in
                [
                    "type": target.type,
                    "value": target.value,
                    "label": target.label,
                    "results": target.results.map { result in
                        [
                            "module": result.moduleName,
                            "summary": result.summary,
                            "riskScore": result.riskScore,
                            "timestamp": ISO8601DateFormatter().string(from: result.timestamp)
                        ]
                    }
                ]
            }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData) {
            try jsonData.write(to: url)
        }
    }
    
    func exportAllInvestigations(context: ModelContext) throws -> URL {
        let investigations = try context.fetch(FetchDescriptor<Investigation>())
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsDir.appendingPathComponent("OSINT_Export_\(Date().timeIntervalSince1970).json")
        
        var exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": AppConfig.appVersion,
            "investigations": investigations.map { inv in
                [
                    "id": inv.id.uuidString,
                    "name": inv.name,
                    "riskScore": inv.riskScore,
                    "targetsCount": inv.targets.count
                ]
            }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys]) {
            try jsonData.write(to: exportURL)
        }
        
        return exportURL
    }
}