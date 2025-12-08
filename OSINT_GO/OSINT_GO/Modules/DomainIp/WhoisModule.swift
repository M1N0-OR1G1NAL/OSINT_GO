//
//  WhoisModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct WhoisModule: OsintModule {
    let name = "WHOIS Lookup"
    let description = "Domain registration data"
    let capabilities: [OsintCapability] = [.whoisLookup]
    let supportedTypes: [TargetType] = [.domain]
    let iconName = "doc.text"
    let color = Color.orange
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        let whoisData = try await context.httpClient.get(
            "https://rdap.arin.net/registry/domain/\(target.value)"
        )
        
        var details: [String: Any] = ["raw": whoisData]
        details["registrar"] = whoisData["events"] as? [[String: Any]]
        details["status"] = whoisData["status"] as? [String]
        
        let riskScore = whoisData["events"] != nil ? 0.2 : 0.5
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "WHOIS data retrieved for \(target.value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
}
