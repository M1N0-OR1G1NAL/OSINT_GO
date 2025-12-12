//
//  PersonModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct PersonModule: OsintModule {
    let name = "Person Name OSINT"
    let capabilities: [OsintCapability] = [.personSearch]
    let supportedTypes: [TargetType] = [.personName]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.0
        
        let personName = target.value.trimmingCharacters(in: .whitespaces)
        
        // Parse name (simplified)
        let nameComponents = personName.split(separator: " ")
        details["jméno"] = nameComponents.first.map(String.init) ?? ""
        details["příjmení"] = nameComponents.dropFirst().joined(separator: " ")
        
        // Generate comprehensive search queries
        let queries = generatePersonSearchQueries(personName)
        details["vyhledávací_dotazy"] = queries
        
        // Generate social media specific queries
        let socialQueries = generateSocialMediaQueries(personName)
        details["sociální_sítě"] = socialQueries
        
        // Generate professional queries
        let professionalQueries = generateProfessionalQueries(personName)
        details["profesní_sítě"] = professionalQueries
        
        // Generate Czech-specific queries
        let czechQueries = generateCzechSpecificQueries(personName)
        details["české_zdroje"] = czechQueries
        
        riskScore = 0.3
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Generated comprehensive search queries for: \(personName)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generatePersonSearchQueries(_ name: String) -> [String: String] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        return [
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            "Google (ČR)": "https://www.google.cz/search?q=\"\(encoded)\"",
            "Google Images": "https://www.google.com/search?q=\"\(encoded)\"&tbm=isch",
            "DuckDuckGo": "https://duckduckgo.com/?q=\"\(encoded)\"",
            "Bing": "https://www.bing.com/search?q=\"\(encoded)\"",
            "Yandex": "https://yandex.com/search/?text=\"\(encoded)\""
        ]
    }
    
    private func generateSocialMediaQueries(_ name: String) -> [String: String] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        return [
            "Facebook": "https://www.facebook.com/search/top?q=\(encoded)",
            "Instagram": "https://www.instagram.com/explore/tags/\(encoded.replacingOccurrences(of: " ", with: ""))/",
            "Twitter/X": "https://twitter.com/search?q=\"\(encoded)\"",
            "LinkedIn": "https://www.linkedin.com/search/results/people/?keywords=\(encoded)",
            "TikTok": "https://www.tiktok.com/search?q=\(encoded)",
            "YouTube": "https://www.youtube.com/results?search_query=\"\(encoded)\"",
            "Pinterest": "https://www.pinterest.com/search/pins/?q=\(encoded)",
            "Reddit": "https://www.reddit.com/search/?q=\"\(encoded)\"",
            "Telegram": "https://www.google.com/search?q=site:t.me+\"\(encoded)\"",
            "WhatsApp Groups": "https://www.google.com/search?q=site:chat.whatsapp.com+\"\(encoded)\""
        ]
    }
    
    private func generateProfessionalQueries(_ name: String) -> [String: String] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        return [
            "LinkedIn": "https://www.linkedin.com/search/results/people/?keywords=\(encoded)",
            "GitHub": "https://github.com/search?q=\"\(encoded)\"&type=users",
            "StackOverflow": "https://stackoverflow.com/users?tab=users&search=\"\(encoded)\"",
            "Academia.edu": "https://www.academia.edu/search?q=\"\(encoded)\"",
            "ResearchGate": "https://www.researchgate.net/search/researcher?q=\"\(encoded)\"",
            "Google Scholar": "https://scholar.google.com/scholar?q=\"\(encoded)\"",
            "Crunchbase": "https://www.crunchbase.com/search/people/\(encoded)"
        ]
    }
    
    private func generateCzechSpecificQueries(_ name: String) -> [String: String] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        return [
            "MPSV (Insolvence)": "https://isir.justice.cz/isir/common/search.do?name=\"\(encoded)\"",
            "Justice.cz": "https://www.justice.cz/web/guest/vyhledavani?p_p_id=searchportlet_WAR_isvjportlet&q=\"\(encoded)\"",
            "Rejstřík trestů": "Manual check - requires official request",
            "Czech.cz": "https://www.google.com/search?q=site:*.cz+\"\(encoded)\"",
            "České noviny": "https://www.google.com/search?q=site:idnes.cz+OR+site:novinky.cz+OR+site:aktualne.cz+\"\(encoded)\"",
            "Firmy.cz (jako osoba)": "https://www.google.com/search?q=site:firmy.cz+\"\(encoded)\"",
            "Seznam.cz": "https://search.seznam.cz/?q=\"\(encoded)\"",
            "Spolužáci": "https://www.spoluzaci.cz/hledani/?s=\(encoded)",
            "Czech Newspapers Archive": "https://www.google.com/search?q=site:*.cz+\"\(encoded)\"&tbs=cdr:1,cd_min:1990"
        ]
    }
}
