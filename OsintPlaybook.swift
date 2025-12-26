//
//  OsintPlaybook.swift
//  OSINT
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//

import Foundation

struct OsintPlaybook {
    let name: String
    let capabilities: [OsintCapability]

    static let quickRecon = OsintPlaybook(
        name: "Quick Recon",
        capabilities: [.dnsLookup, .whoisLookup, .ipGeolocation]
    )

    static let deepInfra = OsintPlaybook(
        name: "Deep Infra Scan",
        capabilities: [.dnsLookup, .whoisLookup, .sslAnalysis, .httpBanner]
    )

    static let reputationCheck = OsintPlaybook(
        name: "Reputation Check",
        capabilities: [.ipGeolocation, .whoisLookup]
    )

    static let all: [OsintPlaybook] = [
        quickRecon,
        deepInfra,
        reputationCheck
    ]
}
