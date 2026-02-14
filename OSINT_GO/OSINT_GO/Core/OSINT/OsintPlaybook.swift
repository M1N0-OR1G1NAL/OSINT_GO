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
    
    static let addressInvestigation: Self = (
        name: "Address Investigation",
        capabilities: [.addressLookup, .geocoding, .propertyData]
    )
    
    static let breachMonitoring: Self = (
        name: "Breach & Leak Monitoring",
        capabilities: [.breachCheck, .credentialSearch, .pasteSearch, .emailValidation]
    )
    
    static let comprehensiveRecon: Self = (
        name: "Comprehensive Recon",
        capabilities: [
            .emailValidation,
            .phoneValidation,
            .phoneCarrier,
            .usernameCheck,
            .socialMediaSearch,
            .personSearch,
            .addressLookup,
            .geocoding,
            .breachCheck
        ]
    )
    
    static let fullOSINT: Self = (
        name: "Full OSINT Scan",
        capabilities: OsintCapability.allCases
    )
    
    static var allPlaybooks: [Self] {
        return [
            quickRecon,
            deepInfra,
            reputationCheck,
            personInvestigation,
            companyInvestigation,
            addressInvestigation,
            breachMonitoring,
            comprehensiveRecon,
            fullOSINT
        ]
    }
}
