//
//  CertificateModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct CertificateModule: OsintModule {
    let name = "Certificate Transparency"
    let capabilities: [OsintCapability] = [.certificateTransparency]
    let supportedTypes: [TargetType] = [.domain]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let domain = target.value.trimmingCharacters(in: .whitespaces)
        
        // Generate certificate transparency search queries
        let queries = generateCertificateQueries(domain)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        details["co_je_CT"] = """
        Certificate Transparency (CT) je veřejný log všech SSL/TLS certifikátů.
        Užitečné pro:
        - Objevení subdomén
        - Sledování certifikačních autorit
        - Detekce podezřelých certifikátů
        - Historie SSL certifikátů
        """
        
        details["doporučené_zdroje"] = """
        1. crt.sh - největší CT log database
        2. Censys - pokročilé vyhledávání certifikátů
        3. SSLMate - CT monitoring
        4. Google CT Search - oficiální Google nástroj
        """
        
        details["informace"] = "Certificate Transparency logs jsou veřejné a legální zdroj informací o SSL/TLS certifikátech."
        
        riskScore = 0.1
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Certificate transparency logs for \(domain)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateCertificateQueries(_ domain: String) -> [String: String] {
        let encoded = domain.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? domain
        
        return [
            "crt.sh": "https://crt.sh/?q=\(encoded)",
            "crt.sh (wildcards)": "https://crt.sh/?q=%.%\(encoded)",
            "Censys": "https://search.censys.io/certificates?q=\(encoded)",
            "SSLMate": "https://certspotter.com/api/v0/certs?domain=\(domain)",
            "VirusTotal": "https://www.virustotal.com/gui/domain/\(domain)/details",
            "SecurityTrails": "https://securitytrails.com/domain/\(domain)/dns"
        ]
    }
}
