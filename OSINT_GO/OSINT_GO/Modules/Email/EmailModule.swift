//
//  EmailModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct EmailModule: OsintModule {
    let name = "Email OSINT"
    let capabilities: [OsintCapability] = [.emailValidation]
    let supportedTypes: [TargetType] = [.email]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.0
        
        let email = target.value.trimmingCharacters(in: .whitespaces)
        
        // Validate email format
        let isValid = validateEmailFormat(email)
        details["validní_formát"] = isValid
        
        if isValid {
            // Extract domain
            let components = email.split(separator: "@")
            if components.count == 2 {
                let domain = String(components[1])
                details["doména"] = domain
                
                // Try to get MX records
                do {
                    let mxRecords = try await lookupMXRecords(domain: domain, context: context)
                    details["MX_záznamy"] = mxRecords
                    riskScore = mxRecords.isEmpty ? 0.6 : 0.2
                } catch {
                    details["MX_chyba"] = "Nepodařilo se získat MX záznamy"
                    riskScore = 0.4
                }
                
                // Generate search queries
                let queries = generateSearchQueries(email)
                details["vyhledávací_dotazy"] = queries
            }
        } else {
            details["chyba"] = "Neplatný formát e-mailové adresy"
            riskScore = 0.8
        }
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: isValid ? "Email analyzed: \(email)" : "Invalid email format",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func validateEmailFormat(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func lookupMXRecords(domain: String, context: OsintContext) async throws -> [String] {
        // Use Google DNS API to lookup MX records
        let urlString = "https://dns.google/resolve?name=\(domain)&type=MX"
        
        guard let url = URL(string: urlString) else {
            return []
        }
        
        let data = try await context.httpClient.get(urlString)
        
        if let answers = data["Answer"] as? [[String: Any]] {
            return answers.compactMap { answer in
                if let mxData = answer["data"] as? String {
                    // MX records format: "priority hostname"
                    let parts = mxData.split(separator: " ")
                    return parts.count >= 2 ? String(parts[1]) : mxData
                }
                return nil
            }
        }
        
        return []
    }
    
    private func generateSearchQueries(_ email: String) -> [String: String] {
        let encoded = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        let domain = email.split(separator: "@").last.map { String($0) } ?? ""
        
        return [
            // 1. General Search
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            
            // 2. Developer Platforms
            "GitHub": "https://github.com/search?q=\"\(encoded)\"&type=users",
            "GitLab": "https://gitlab.com/search?search=\"\(encoded)\"",
            "StackOverflow": "https://stackoverflow.com/search?q=\"\(encoded)\"",
            "CodePen": "https://codepen.io/search/pens?q=\"\(encoded)\"",
            
            // 3. Social Networks
            "Facebook": "https://www.facebook.com/search/people/?q=\(encoded)",
            "Twitter/X": "https://twitter.com/search?q=\"\(encoded)\"",
            "LinkedIn": "https://www.linkedin.com/search/results/people/?keywords=\(encoded)",
            "Instagram": "https://www.instagram.com/explore/tags/\(encoded.replacingOccurrences(of: "@", with: "").replacingOccurrences(of: ".", with: ""))/",
            "Reddit": "https://www.reddit.com/search/?q=\"\(encoded)\"",
            
            // 4. Data Breach Databases
            "HaveIBeenPwned": "https://haveibeenpwned.com/account/\(encoded)",
            "Dehashed": "https://dehashed.com/search?query=\(encoded)",
            "LeakCheck": "https://leakcheck.io/search?query=\(encoded)",
            "IntelligenceX": "https://intelx.io/?s=\(encoded)",
            
            // 5. Paste Sites
            "Pastebin": "https://www.google.com/search?q=site:pastebin.com+\"\(encoded)\"",
            "GitHub Gists": "https://gist.github.com/search?q=\"\(encoded)\"",
            "Ghostbin": "https://www.google.com/search?q=site:ghostbin.com+\"\(encoded)\"",
            
            // 6. Forums & Communities
            "Reddit Search": "https://www.google.com/search?q=site:reddit.com+\"\(encoded)\"",
            "Quora": "https://www.quora.com/search?q=\"\(encoded)\"",
            "Hacker News": "https://hn.algolia.com/?q=\"\(encoded)\"",
            
            // 7. Email Verification Services
            "Hunter.io": "https://hunter.io/search/\(domain)",
            "EmailRep": "https://emailrep.io/\(encoded)",
            "Email Checker": "Use email validation APIs",
            
            // 8. Business & Professional
            "Crunchbase": "https://www.crunchbase.com/textsearch?q=\"\(encoded)\"",
            "AngelList": "https://angel.co/search?q=\"\(encoded)\"",
            "Glassdoor": "https://www.glassdoor.com/Search/results.htm?keyword=\"\(encoded)\"",
            
            // 9. Academic & Research
            "Google Scholar": "https://scholar.google.com/scholar?q=\"\(encoded)\"",
            "ResearchGate": "https://www.researchgate.net/search?q=\"\(encoded)\"",
            "Academia.edu": "https://www.academia.edu/search?q=\"\(encoded)\"",
            
            // 10. Additional Sources
            "Gravatar": "https://en.gravatar.com/\(encoded.replacingOccurrences(of: "@", with: "").replacingOccurrences(of: ".", with: ""))",
            "Skype Resolver": "Search for email in Skype directory",
            "VirusTotal": "https://www.virustotal.com/gui/search/\(encoded)",
            "Shodan": "https://www.shodan.io/search?query=\"\(encoded)\"",
            
            // 11. Archive & Historical
            "Wayback Machine": "https://web.archive.org/web/*/\(domain)",
            "Archive.today": "https://archive.fo/\(domain)",
            
            // 12. Reverse Email Lookup
            "TrueCaller": "Use TrueCaller app for reverse lookup",
            "Pipl": "https://pipl.com/search/?q=\"\(encoded)\"",
            "Spokeo": "https://www.spokeo.com/email-search?q=\"\(encoded)\"",
            
            // 13. Czech-specific
            "Seznam Email": "Zkontrolujte Seznam.cz email databázi",
            "Czech Forums": "https://www.google.com/search?q=site:.cz+\"\(encoded)\""
        ]
    }
}
