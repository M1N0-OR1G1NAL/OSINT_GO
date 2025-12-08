//
//  OsintPlaybook.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct OsintPlaybook {
    let name: String
    let capabilities: [OsintCapability]
    
    static let quickRecon: Self = (
        name: "Quick Recon",
        capabilities: [.dnsLookup, .whoisLookup, .ipGeolocation]
    )
    
    static let deepInfra: Self = (
        name: "Deep Infra Scan",
        capabilities: [.dnsLookup, .whoisLookup, .sslAnalysis, .httpBanner]
    )
    
    static let reputationCheck: Self = (
        name: "Reputation Check",
        capabilities: [.ipGeolocation, .whoisLookup]
    )
}
