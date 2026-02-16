//
//  DarkWebModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct DarkWebModule: OsintModule {
    let name = "Dark Web Search"
    let capabilities: [OsintCapability] = [.darkWebSearch]
    let supportedTypes: [TargetType] = [.email, .username, .domain, .company]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        
        // Generate dark web search queries (surface web access points only)
        let queries = generateDarkWebQueries(value)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        details["co_je_dark_web"] = """
        Dark Web je část internetu vyžadující speciální software (Tor, I2P).
        Obsahuje:
        - Anonymní fóra a tržiště
        - Leaked databases
        - Privátní komunikační platformy
        - Někdy i legální obsah (whistleblowing, novinařina)
        """
        
        details["přístupové_body"] = """
        Pro bezpečný přístup k informacím o Dark Webu:
        1. Ahmia.fi - Tor search engine (surface web přístup)
        2. IntelligenceX - agregátor dark web dat
        3. DarkSearch.io - dark web search
        4. Onion.live - katalog .onion stránek
        """
        
        details["bezpečnostní_upozornění"] = """
        ⚠️ DŮLEŽITÉ BEZPEČNOSTNÍ UPOZORNĚNÍ:
        - Nikdy nepřistupujte k dark webu bez VPN a Tor Browser
        - Neotevírejte podezřelé odkazy
        - Nestahujte soubory z neověřených zdrojů
        - Některý obsah může být nelegální
        - Doporučujeme pouze pasivní OSINT přes clearnet nástroje
        """
        
        details["legální_poznámka"] = "Tento modul poskytuje pouze odkazy na legální vyhledávače a katalogy. Uživatel je odpovědný za dodržování zákonů své jurisdikce."
        
        // Higher risk score due to sensitive nature
        riskScore = 0.5
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Dark web search resources for \(value) (passive only)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateDarkWebQueries(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        
        return [
            "Ahmia (Tor Search)": "https://ahmia.fi/search/?q=\(encoded)",
            "DarkSearch": "https://darksearch.io/search?query=\(encoded)",
            "IntelligenceX": "https://intelx.io/?s=\(encoded)",
            "Onion.live": "https://onion.live/",
            "Dark.fail": "https://dark.fail/",
            "Google (onion refs)": "https://www.google.com/search?q=\"\(encoded)\"+.onion",
            "Paste monitoring": "https://www.google.com/search?q=site:pastebin.com+OR+site:ghostbin.com+\"\(encoded)\"",
            "Breach forums": "⚠️ Manual research required - exercise extreme caution"
        ]
    }
}
