//
//  OsintCapability.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

enum OsintCapability: String, CaseIterable {
    case dnsLookup = "DNS Lookup"
    case whoisLookup = "WHOIS"
    case ipGeolocation = "IP Geolokace"
    case sslAnalysis = "SSL Analýza"
    case httpBanner = "HTTP Banner"
    case emailValidation = "Email Validace"
    case usernameCheck = "Username Check"
    case companyLookup = "Firma"
}
