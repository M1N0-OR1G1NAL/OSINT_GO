//
//  DomainIpModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct DomainIpModule: OsintModule {
    let name = "Domain/IP Analysis"
    let capabilities: [OsintCapability] = [.dnsLookup, .whoisLookup, .ipGeolocation, .sslAnalysis]
    let supportedTypes: [TargetType] = [.domain, .ipAddress]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0

        switch TargetType(rawValue: target.type) {
        case .domain:
            let dns = try await context.httpClient.get("https://dns.google/resolve?name=\(target.value)")
            details["DNS"] = ModuleResult.detailString(from: dns)
            riskScore += 0.3

        case .ipAddress:
            let ipInfo = try await context.httpClient.get("https://ipinfo.io/\(target.value)/json")
            details["IPInfo"] = ModuleResult.detailString(from: ipInfo)
            riskScore += 0.2

        default: break
        }

        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Analysis completed for \(target.value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
}
