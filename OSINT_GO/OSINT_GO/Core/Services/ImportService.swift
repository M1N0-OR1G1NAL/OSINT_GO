//
//  ImportService.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI
import SwiftData

enum ImportError: LocalizedError {
    case invalidFileFormat
    case invalidJSON
    case missingRequiredFields
    case versionMismatch
    case duplicateInvestigation
    
    var errorDescription: String? {
        switch self {
        case .invalidFileFormat:
            return "Invalid file format. Please select a valid OSINT export JSON file."
        case .invalidJSON:
            return "Failed to parse JSON. The file may be corrupted."
        case .missingRequiredFields:
            return "Export file is missing required fields."
        case .versionMismatch:
            return "Export was created with an incompatible app version."
        case .duplicateInvestigation:
            return "An investigation with this ID already exists."
        }
    }
}

class ImportService {
    static let shared = ImportService()
    
    func importInvestigations(from url: URL, context: ModelContext) throws -> Int {
        // Ensure we have access to the file
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.invalidFileFormat
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Read the JSON data
        let data = try Data(contentsOf: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ImportError.invalidJSON
        }
        
        // Validate export structure
        guard let exportDate = json["exportDate"] as? String,
              let appVersion = json["appVersion"] as? String,
              let investigationsData = json["investigations"] as? [[String: Any]] else {
            throw ImportError.missingRequiredFields
        }
        
        // Check version compatibility (allow 1.0.x and 1.1.x)
        if !appVersion.hasPrefix("1.0") && !appVersion.hasPrefix("1.1") {
            throw ImportError.versionMismatch
        }
        
        var importedCount = 0
        let existingInvestigations = try context.fetch(FetchDescriptor<Investigation>())
        let existingIDs = Set(existingInvestigations.map { $0.id })
        
        // Import investigations
        for invData in investigationsData {
            guard let idString = invData["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = invData["name"] as? String else {
                continue
            }
            
            // Skip if already exists
            if existingIDs.contains(id) {
                continue
            }
            
            let investigation = Investigation(name: "\(name) (Imported)")
            investigation.id = id
            
            if let riskScore = invData["riskScore"] as? Double {
                investigation.riskScore = riskScore
            }
            
            context.insert(investigation)
            importedCount += 1
        }
        
        try context.save()
        return importedCount
    }
    
    func importFullInvestigation(from url: URL, context: ModelContext) throws {
        // Ensure we have access to the file
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.invalidFileFormat
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Read the JSON data
        let data = try Data(contentsOf: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ImportError.invalidJSON
        }
        
        // Validate basic structure
        guard let name = json["name"] as? String,
              let createdAtString = json["createdAt"] as? String,
              let targetsData = json["targets"] as? [[String: Any]] else {
            throw ImportError.missingRequiredFields
        }
        
        // Create new investigation
        let investigation = Investigation(name: "\(name) (Imported)")
        
        // Parse date
        let dateFormatter = ISO8601DateFormatter()
        if let createdAt = dateFormatter.date(from: createdAtString) {
            investigation.createdAt = createdAt
        }
        
        if let riskScore = json["riskScore"] as? Double {
            investigation.riskScore = riskScore
        }
        
        // Parse targets
        for targetData in targetsData {
            guard let typeString = targetData["type"] as? String,
                  let value = targetData["value"] as? String,
                  let label = targetData["label"] as? String,
                  let targetType = TargetType(rawValue: typeString) else {
                continue
            }
            
            let target = Target(type: targetType, value: value, label: label)
            
            // Parse results if present
            if let resultsData = targetData["results"] as? [[String: Any]] {
                for resultData in resultsData {
                    guard let moduleName = resultData["module"] as? String,
                          let summary = resultData["summary"] as? String,
                          let riskScore = resultData["riskScore"] as? Double,
                          let timestampString = resultData["timestamp"] as? String,
                          let timestamp = dateFormatter.date(from: timestampString) else {
                        continue
                    }
                    
                    let result = ModuleResult(
                        moduleName: moduleName,
                        targetId: target.id,
                        summary: summary,
                        details: [:],
                        riskScore: riskScore,
                        timestamp: timestamp
                    )
                    target.results.append(result)
                }
            }
            
            investigation.targets.append(target)
        }
        
        context.insert(investigation)
        try context.save()
    }
}
