//
//  PhoneModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct PhoneModule: OsintModule {
    let name = "Phone OSINT"
    let capabilities: [OsintCapability] = [.phoneValidation, .phoneCarrier]
    let supportedTypes: [TargetType] = [.phone]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.0
        
        let phoneNumber = target.value.replacingOccurrences(of: " ", with: "")
        
        // Basic validation
        let isValid = validatePhoneFormat(phoneNumber)
        details["validní_formát"] = isValid
        
        if isValid {
            // Extract country code and number info
            let info = extractPhoneInfo(phoneNumber)
            details["země"] = info.country
            details["region"] = info.region
            details["typ"] = info.type
            
            // Formats
            details["formáty"] = [
                "E.164": formatE164(phoneNumber),
                "mezinárodní": formatInternational(phoneNumber),
                "národní": formatNational(phoneNumber)
            ]
            
            // Generate search queries
            let queries = generateSearchQueries(phoneNumber)
            details["vyhledávací_dotazy"] = queries
            
            riskScore = 0.1
        } else {
            details["chyba"] = "Neplatný formát telefonního čísla"
            riskScore = 0.5
        }
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: isValid ? "Phone number analyzed: \(phoneNumber)" : "Invalid phone number format",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func validatePhoneFormat(_ phone: String) -> Bool {
        // Basic validation - starts with + and contains only digits
        let cleaned = phone.replacingOccurrences(of: "+", with: "")
        return phone.hasPrefix("+") && cleaned.count >= 10 && cleaned.count <= 15 && cleaned.allSatisfy { $0.isNumber }
    }
    
    private func extractPhoneInfo(_ phone: String) -> (country: String, region: String, type: String) {
        // Extract country code (simplified)
        let cleaned = phone.replacingOccurrences(of: "+", with: "")
        
        if cleaned.hasPrefix("420") {
            return ("Česká republika", "CZ", determineCzechType(cleaned))
        } else if cleaned.hasPrefix("421") {
            return ("Slovensko", "SK", "Mobil/Pevná")
        } else if cleaned.hasPrefix("1") {
            return ("USA/Kanada", "US/CA", "Mobil/Pevná")
        } else if cleaned.hasPrefix("44") {
            return ("Velká Británie", "GB", "Mobil/Pevná")
        } else if cleaned.hasPrefix("49") {
            return ("Německo", "DE", "Mobil/Pevná")
        }
        
        return ("Neznámá", "Unknown", "Neznámý")
    }
    
    private func determineCzechType(_ phone: String) -> String {
        // Czech mobile prefixes: 60x, 70x, 72x, 73x, 77x, 79x
        if phone.count >= 5 {
            let prefix = String(phone.prefix(5))
            if prefix.hasPrefix("42060") || prefix.hasPrefix("42070") || 
               prefix.hasPrefix("42072") || prefix.hasPrefix("42073") ||
               prefix.hasPrefix("42077") || prefix.hasPrefix("42079") {
                return "Mobil"
            }
        }
        return "Pevná/Jiný"
    }
    
    private func formatE164(_ phone: String) -> String {
        return phone.hasPrefix("+") ? phone : "+\(phone)"
    }
    
    private func formatInternational(_ phone: String) -> String {
        let cleaned = phone.replacingOccurrences(of: "+", with: "")
        if cleaned.hasPrefix("420") && cleaned.count >= 12 {
            let code = String(cleaned.prefix(3))
            let rest = String(cleaned.suffix(cleaned.count - 3))
            return "+\(code) \(formatWithSpaces(rest))"
        }
        return "+\(formatWithSpaces(cleaned))"
    }
    
    private func formatNational(_ phone: String) -> String {
        let cleaned = phone.replacingOccurrences(of: "+", with: "")
        if cleaned.hasPrefix("420") {
            return formatWithSpaces(String(cleaned.suffix(cleaned.count - 3)))
        }
        return formatWithSpaces(cleaned)
    }
    
    private func formatWithSpaces(_ number: String) -> String {
        var result = ""
        for (index, char) in number.enumerated() {
            if index > 0 && index % 3 == 0 {
                result += " "
            }
            result += String(char)
        }
        return result
    }
    
    private func generateSearchQueries(_ phone: String) -> [String: String] {
        let cleaned = phone.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")
        let withSpaces = formatWithSpaces(cleaned)
        let withPlus = "+\(cleaned)"
        
        return [
            "Google (s +)": "https://www.google.com/search?q=\"\(withPlus)\"",
            "Google (bez +)": "https://www.google.com/search?q=\"\(cleaned)\"",
            "Google (s mezerami)": "https://www.google.com/search?q=\"\(withSpaces.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? withSpaces)\"",
            "Inzerce": "https://www.google.com/search?q=site:sbazar.cz+OR+site:sreality.cz+OR+site:bazoš.cz+\"\(cleaned)\"",
            "Fóra": "https://www.google.com/search?q=site:forum.* OR site:*forum.cz \"\(cleaned)\""
        ]
    }
}
