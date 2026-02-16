//
//  BreachModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct BreachModule: OsintModule {
    let name = "Data Breach Search"
    let capabilities: [OsintCapability] = [.breachSearch]
    let supportedTypes: [TargetType] = [.email, .username, .domain]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        
        // Generate search queries for breach databases
        let queries = generateBreachQueries(value)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        // Information about breach checking
        details["doporučení"] = """
        Pro kontrolu úniků dat doporučujeme:
        1. HaveIBeenPwned (https://haveibeenpwned.com/)
        2. DeHashed (https://dehashed.com/)
        3. LeakCheck (https://leakcheck.io/)
        4. IntelligenceX (https://intelx.io/)
        """
        
        details["upozornění"] = "Tato funkce poskytuje odkazy na služby pro kontrolu úniků. Skutečná kontrola vyžaduje manuální ověření na těchto platformách."
        
        // Risk score is neutral until actual breach is confirmed
        riskScore = 0.3
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Generated breach search queries for \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateBreachQueries(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        
        return [
            "HaveIBeenPwned": "https://haveibeenpwned.com/",
            "DeHashed": "https://dehashed.com/search?query=\(encoded)",
            "LeakCheck": "https://leakcheck.io/",
            "IntelligenceX": "https://intelx.io/",
            "Google (data breaches)": "https://www.google.com/search?q=\"\(encoded)\"+\"data+breach\"+OR+\"leaked\"+OR+\"database+dump\"",
            "Pastebin search": "https://www.google.com/search?q=site:pastebin.com+\"\(encoded)\"",
            "GitHub Gists": "https://www.google.com/search?q=site:gist.github.com+\"\(encoded)\"",
            "Paste sites": "https://www.google.com/search?q=site:paste.ee+OR+site:ghostbin.com+OR+site:privatebin.net+\"\(encoded)\""
        ]
    }
}
