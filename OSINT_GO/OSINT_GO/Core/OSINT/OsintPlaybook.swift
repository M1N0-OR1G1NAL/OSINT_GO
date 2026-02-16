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

    static let personInvestigation = OsintPlaybook(
        name: "Person Investigation",
        capabilities: [.personSearch, .socialMediaSearch, .emailValidation]
    )

    static let companyInvestigation = OsintPlaybook(
        name: "Company Investigation",
        capabilities: [.companyLookup, .icoLookup, .whoisLookup]
    )

    static let fullOSINT = OsintPlaybook(
        name: "Full OSINT Scan",
        capabilities: OsintCapability.allCases
    )
}
