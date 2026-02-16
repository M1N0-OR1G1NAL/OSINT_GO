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
    case phoneValidation = "Validace telefonu"
    case phoneCarrier = "Operátor telefonu"
    case companyLookup = "Firma"
    case icoLookup = "IČO Lookup"
    case personSearch = "Vyhledávání osoby"
    case socialMediaSearch = "Social Media"
    case addressLookup = "Vyhledávání adresy"
    case geocoding = "Geokódování"
    case propertyData = "Nemovitostní data"
    case breachCheck = "Kontrola úniku dat"
    case credentialSearch = "Vyhledávání přihlašovacích údajů"
    case pasteSearch = "Vyhledávání paste"
}
