//
//  OsintCapability.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

enum OsintCapability: String, CaseIterable {
    // Existing capabilities
    case dnsLookup = "DNS Lookup"
    case whoisLookup = "WHOIS"
    case ipGeolocation = "IP Geolokace"
    case sslAnalysis = "SSL Analýza"
    case httpBanner = "HTTP Banner"
    case emailValidation = "Email Validace"
    case usernameCheck = "Username Check"
    case phoneValidation = "Validace telefonu"
    case phoneCarrier = "Operátor telefonu"
    case companyLookup = "Firma"
    case icoLookup = "IČO Lookup"
    case personSearch = "Vyhledávání osoby"
    case socialMediaSearch = "Social Media"
    
    // New capabilities - inspired by OSINT Framework
    case breachSearch = "Data Breach Search"
    case subdomainEnumeration = "Subdomain Enumeration"
    case metadataExtraction = "Metadata Extraction"
    case pasteSiteSearch = "Paste Site Search"
    case certificateTransparency = "Certificate Transparency"
    case codeRepositorySearch = "Code Repository Search"
    case darkWebSearch = "Dark Web Search"
    case socialAnalytics = "Social Analytics"
    case reverseImageSearch = "Reverse Image Search"
    case advancedGeolocation = "Advanced Geolocation"
}
