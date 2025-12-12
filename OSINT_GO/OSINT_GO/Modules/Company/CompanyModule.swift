//
//  CompanyModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct CompanyModule: OsintModule {
    let name = "Company/IČO OSINT"
    let capabilities: [OsintCapability] = [.companyLookup, .icoLookup]
    let supportedTypes: [TargetType] = [.company, .ico]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        
        if TargetType(rawValue: target.type) == .ico {
            // IČO lookup
            let isValid = validateICO(value)
            details["validní_IČO"] = isValid
            
            if isValid {
                // Try to fetch company info from ARES
                do {
                    let companyInfo = try await lookupARES(ico: value, context: context)
                    details["firma"] = companyInfo
                    riskScore = 0.2
                } catch {
                    details["chyba"] = "Nepodařilo se získat údaje z ARES: \(error.localizedDescription)"
                    riskScore = 0.4
                }
                
                // Generate search queries
                let queries = generateICOSearchQueries(value)
                details["vyhledávací_dotazy"] = queries
            } else {
                details["chyba"] = "Neplatný formát IČO"
                riskScore = 0.7
            }
        } else {
            // Company name lookup
            let queries = generateCompanySearchQueries(value)
            details["vyhledávací_dotazy"] = queries
            riskScore = 0.3
        }
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Company/IČO analysis completed for: \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func validateICO(_ ico: String) -> Bool {
        // Czech IČO is 8 digits
        let cleaned = ico.replacingOccurrences(of: " ", with: "")
        guard cleaned.count == 8, cleaned.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        // Validate checksum
        let digits = cleaned.compactMap { Int(String($0)) }
        var sum = 0
        for i in 0..<7 {
            sum += digits[i] * (8 - i)
        }
        let remainder = sum % 11
        let checkDigit = remainder == 0 ? 1 : remainder == 1 ? 0 : 11 - remainder
        
        return checkDigit == digits[7]
    }
    
    private func lookupARES(ico: String, context: OsintContext) async throws -> [String: Any] {
        // ARES API endpoint (simplified - real implementation would need XML parsing)
        let urlString = "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/\(ico)"
        
        do {
            let data = try await context.httpClient.get(urlString)
            
            var result: [String: Any] = [:]
            result["IČO"] = ico
            result["data"] = data
            
            // Try to extract basic info (simplified)
            if let obchodniJmeno = data["obchodniJmeno"] as? String {
                result["název"] = obchodniJmeno
            }
            if let sidlo = data["sidlo"] as? [String: Any] {
                result["sídlo"] = sidlo
            }
            
            return result
        } catch {
            // Fallback to alternative sources
            return [
                "IČO": ico,
                "poznámka": "ARES nedostupné, zkuste Justice.cz nebo OR.cz",
                "justice_url": "https://or.justice.cz/ias/ui/rejstrik-$firma?ico=\(ico)",
                "orcz_url": "https://www.or.cz/\(ico)"
            ]
        }
    }
    
    private func generateICOSearchQueries(_ ico: String) -> [String: String] {
        return [
            "ARES": "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/\(ico)",
            "Justice.cz": "https://or.justice.cz/ias/ui/rejstrik-$firma?ico=\(ico)",
            "OR.cz": "https://www.or.cz/\(ico)",
            "Google": "https://www.google.com/search?q=IČO+\(ico)",
            "Firmy.cz": "https://www.firmy.cz/detail/\(ico)",
            "Seznamfirm.cz": "https://www.seznamfirm.cz/search?q=\(ico)"
        ]
    }
    
    private func generateCompanySearchQueries(_ companyName: String) -> [String: String] {
        let encoded = companyName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? companyName
        
        return [
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            "Justice.cz": "https://or.justice.cz/ias/ui/rejstrik-$firma?nazev=\"\(encoded)\"",
            "Firmy.cz": "https://www.firmy.cz/search?q=\"\(encoded)\"",
            "LinkedIn": "https://www.linkedin.com/search/results/companies/?keywords=\(encoded)",
            "Google (sociální sítě)": "https://www.google.com/search?q=site:facebook.com+OR+site:linkedin.com+\"\(encoded)\"",
            "Google (recenze)": "https://www.google.com/search?q=\"\(encoded)\"+recenze+OR+hodnocení"
        ]
    }
}
