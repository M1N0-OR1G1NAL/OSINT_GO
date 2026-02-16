//
//  SubdomainModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct SubdomainModule: OsintModule {
    let name = "Subdomain Enumeration"
    let capabilities: [OsintCapability] = [.subdomainEnumeration]
    let supportedTypes: [TargetType] = [.domain]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let domain = target.value.trimmingCharacters(in: .whitespaces)
        
        // Generate subdomain search queries
        let queries = generateSubdomainQueries(domain)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        // Common subdomain patterns to check
        let commonSubdomains = [
            "www", "mail", "ftp", "admin", "webmail", "smtp", "pop", "ns1", "ns2",
            "cpanel", "whm", "autodiscover", "autoconfig", "m", "mobile", "api",
            "dev", "staging", "test", "beta", "vpn", "remote", "blog", "shop"
        ]
        
        details["běžné_subdomény"] = commonSubdomains.joined(separator: ", ")
        
        details["doporučené_nástroje"] = """
        Pro aktivní enumeraci subdomén doporučujeme:
        1. crt.sh - Certificate Transparency logs
        2. SecurityTrails - DNS history
        3. DNSdumpster - DNS recon tool
        4. Sublist3r - Subdomain enumeration tool
        5. Amass - Advanced subdomain discovery
        """
        
        details["upozornění"] = "Aktivní skenování může být detekováno. Doporučujeme pasivní metody přes Certificate Transparency a DNS záznamy."
        
        riskScore = 0.2
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Subdomain enumeration resources for \(domain)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateSubdomainQueries(_ domain: String) -> [String: String] {
        let encoded = domain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? domain
        
        return [
            "crt.sh": "https://crt.sh/?q=%25.\(domain)",
            "SecurityTrails": "https://securitytrails.com/domain/\(domain)/subdomains",
            "DNSdumpster": "https://dnsdumpster.com/",
            "VirusTotal": "https://www.virustotal.com/gui/domain/\(domain)/relations",
            "Shodan": "https://www.shodan.io/search?query=hostname:\(encoded)",
            "Censys": "https://search.censys.io/search?resource=hosts&q=\(encoded)",
            "Google": "https://www.google.com/search?q=site:*.\(encoded)",
            "Wayback Machine": "https://web.archive.org/web/*/\(encoded)/*"
        ]
    }
}
