import Foundation

enum OsintCapability: String, CaseIterable {
        // Domain / IP
    case dnsLookup = "DNS Lookup"
    case whoisLookup = "WHOIS"
    case httpBanner = "HTTP Banner"
    case sslAnalysis = "SSL Analýza"
    case reverseDNS = "Reverse DNS"

        // Network
    case ipGeolocation = "IP Geolokace"
    case abuseReputation = "Abuse / Reputation"
    case asnInfo = "ASN Info"

        // Email
    case emailValidation = "Email Validation"
    case dorkGeneration = "Dork Generation"
    case gravatarCheck = "Gravatar Check"

        // Username
    case usernameCheck = "Username Check"
    case usernamePattern = "Username Pattern"

        // Company / Person
    case companyLookup = "Company Lookup"
    case personSearch = "Person Search"

        // Media
    case webContent = "Web Content Analysis"
    case imageAnalysis = "Image Analysis"
    case documentAnalysis = "Document Analysis"

        // Geo / Map
    case geoMapping = "Geo Mapping"

        // Analytics
    case graphAnalysis = "Graph Analysis"
    case riskScoring = "Risk Scoring"
    case timeline = "Timeline"

        // Future / ML
    case llmCorrelation = "LLM Correlation"
    case disinfoDetection = "Disinfo Detection"

        // UI/AR
    case arOverlay = "AR Overlay"
}
