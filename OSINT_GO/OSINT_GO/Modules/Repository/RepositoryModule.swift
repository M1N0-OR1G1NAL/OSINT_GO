//
//  RepositoryModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct RepositoryModule: OsintModule {
    let name = "Code Repository Search"
    let capabilities: [OsintCapability] = [.codeRepositorySearch]
    let supportedTypes: [TargetType] = [.email, .username, .domain, .company]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        
        // Generate repository search queries
        let queries = generateRepositoryQueries(value)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        details["co_hledat"] = """
        V kódových repozitářích můžete najít:
        - API klíče a credentials (často nechtěně commitnuté)
        - E-mailové adresy vývojářů
        - Interní dokumentaci
        - Konfigurační soubory
        - Historie commitů s informacemi
        - Dependencies a použité technologie
        """
        
        details["doporučené_platformy"] = """
        1. GitHub - největší platforma pro code hosting
        2. GitLab - open-source alternativa
        3. Bitbucket - často používán v korporacích
        4. SourceForge - starší projekty
        5. Codeberg - open-source friendly
        """
        
        details["bezpečnostní_poznámka"] = "Věnujte pozornost citlivým informacím jako jsou API klíče, hesla nebo credentials, které mohly být omylem zveřejněny."
        
        riskScore = 0.3
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Code repository search for \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateRepositoryQueries(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        
        return [
            "GitHub Code": "https://github.com/search?q=\"\(encoded)\"&type=code",
            "GitHub Users": "https://github.com/search?q=\"\(encoded)\"&type=users",
            "GitHub Repos": "https://github.com/search?q=\"\(encoded)\"&type=repositories",
            "GitHub Commits": "https://github.com/search?q=\"\(encoded)\"&type=commits",
            "GitLab": "https://gitlab.com/search?search=\(encoded)",
            "Bitbucket": "https://bitbucket.org/repo/all?name=\(encoded)",
            "SourceForge": "https://sourceforge.net/directory/?q=\(encoded)",
            "Google (repos)": "https://www.google.com/search?q=site:github.com+OR+site:gitlab.com+\"\(encoded)\"",
            "Secrets search": "https://github.com/search?q=\"\(encoded)\"+password+OR+api_key+OR+secret&type=code"
        ]
    }
}
