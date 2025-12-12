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
    
    static let personInvestigation: Self = (
        name: "Person Investigation",
        capabilities: [.personSearch, .socialMediaSearch, .emailValidation]
    )
    
    static let companyInvestigation: Self = (
        name: "Company Investigation",
        capabilities: [.companyLookup, .icoLookup, .whoisLookup]
    )
    
    static let fullOSINT: Self = (
        name: "Full OSINT Scan",
        capabilities: OsintCapability.allCases
    )
}
