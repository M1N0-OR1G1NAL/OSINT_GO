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
        var details: [String: String] = [:]
        var riskScore: Double = 0.0

        let email = target.value.trimmingCharacters(in: .whitespaces)

        // Validate email format
        let isValid = validateEmailFormat(email)
        details["validní_formát"] = isValid ? "true" : "false"

        if isValid {
            // Extract domain
            let components = email.split(separator: "@")
            if components.count == 2 {
                let domain = String(components[1])
                details["doména"] = domain

                // Try to get MX records
                do {
                    let mxRecords = try await lookupMXRecords(domain: domain, context: context)
                    details["MX_záznamy"] = mxRecords.joined(separator: ", ")
                    riskScore = mxRecords.isEmpty ? 0.6 : 0.2
                } catch {
                    details["MX_chyba"] = "Nepodařilo se získat MX záznamy"
                    riskScore = 0.4
                }

                // Generate search queries
                let queries = generateSearchQueries(email)
                let joinedQueries = queries
                    .map { "\($0.key): \($0.value)" }
                    .joined(separator: "\n")
                details["vyhledávací_dotazy"] = joinedQueries
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
        
        return [
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            "GitHub": "https://github.com/search?q=\"\(encoded)\"&type=users",
            "Pastebin": "https://www.google.com/search?q=site:pastebin.com+\"\(encoded)\"",
            "Sociální sítě": "https://www.google.com/search?q=site:facebook.com+OR+site:twitter.com+OR+site:linkedin.com+\"\(encoded)\"",
            "Fóra a diskuze": "https://www.google.com/search?q=site:reddit.com+OR+site:*.forum.*+\"\(encoded)\"",
            "Data breaches": "https://www.google.com/search?q=\"\(encoded)\"+\"data+breach\"+OR+\"leaked\""
        ]
    }
}
