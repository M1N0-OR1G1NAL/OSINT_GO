//
//  DNSModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftUI

struct DNSModule: OsintModule {
    let name = "DNS Lookup"
    let description = "A, MX, NS, TXT records"
    let capabilities: [OsintCapability] = [.dnsLookup]
    let supportedTypes: [TargetType] = [.domain]
    let iconName = "network"
    let color = Color.blue
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        let dnsData = try await context.httpClient.get(
            "https://dns.google/resolve?name=\(target.value)&type=ALL"
        )
        
        var details: [String: Any] = ["raw": dnsData]
        
        if let answer = (dnsData["Answer"] as? [[String: Any]]), !answer.isEmpty {
            details["A Records"] = answer.compactMap { $0["data"] as? String }
            details["MX Records"] = answer.compactMap { ($0["data"] as? String)?.replacingOccurrences(of: " ", with: "") }
        }
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Found \(details["A Records"]?.count ?? 0) A records",
            details: details,
            riskScore: 0.1,
            timestamp: Date()
        )
    }
}
