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
    
    // Czech mobile prefixes
    private let czechMobilePrefixes = ["42060", "42070", "42072", "42073", "42077", "42079"]
    
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
            if czechMobilePrefixes.contains(where: { prefix.hasPrefix($0) }) {
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
        let encoded = cleaned.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleaned
        
        return [
            // 1. General Search Engines (multiple formats)
            "Google (s +)": "https://www.google.com/search?q=\"\(withPlus)\"",
            "Google (bez +)": "https://www.google.com/search?q=\"\(cleaned)\"",
            "Google (s mezerami)": "https://www.google.com/search?q=\"\(withSpaces.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? withSpaces)\"",
            "DuckDuckGo": "https://duckduckgo.com/?q=\"\(encoded)\"",
            "Bing": "https://www.bing.com/search?q=\"\(encoded)\"",
            
            // 2. Reverse Phone Lookup Services
            "TrueCaller": "https://www.truecaller.com/search/\(encoded)",
            "Sync.me": "https://sync.me/",
            "Whoscall": "Use Whoscall app for caller ID",
            "Number Guru": "Reverse phone lookup service",
            "ZabaSearch": "https://www.zabasearch.com/",
            
            // 3. Czech Classifieds & Marketplace
            "Sbazar.cz": "https://www.google.com/search?q=site:sbazar.cz+\"\(cleaned)\"",
            "Sreality.cz": "https://www.google.com/search?q=site:sreality.cz+\"\(cleaned)\"",
            "Bazos.cz": "https://www.google.com/search?q=site:bazos.cz+\"\(cleaned)\"",
            "Sauto.cz": "https://www.google.com/search?q=site:sauto.cz+\"\(cleaned)\"",
            "Hyperinzerce": "https://www.google.com/search?q=site:hyperinzerce.cz+\"\(cleaned)\"",
            
            // 4. Social Media
            "Facebook": "https://www.facebook.com/search/people/?q=\(encoded)",
            "WhatsApp": "Use WhatsApp to check if number is registered",
            "Telegram": "Use Telegram to search by phone number",
            "Viber": "Check Viber directory",
            "Signal": "Check if number is registered",
            
            // 5. Business Directories
            "Firmy.cz": "https://www.google.com/search?q=site:firmy.cz+\"\(cleaned)\"",
            "Zlaté stránky": "https://www.zlatestranky.cz/hledej.php?q=\(encoded)",
            "Yellow Pages (US)": "https://www.yellowpages.com/search?search_terms=\(encoded)",
            
            // 6. Forums & Communities
            "Czech Forums": "https://www.google.com/search?q=site:forum.* OR site:*forum.cz \"\(cleaned)\"",
            "Reddit": "https://www.google.com/search?q=site:reddit.com+\"\(cleaned)\"",
            
            // 7. Messaging Apps Check
            "iMessage Check": "Use Apple device to check if number uses iMessage",
            "WhatsApp Business": "Check if registered as business",
            
            // 8. Carrier & Validation
            "Carrier Lookup": "Use NumVerify API for carrier info",
            "Phone Validator": "Use Twilio Lookup API",
            "Numspy": "https://www.numspy.cz/ for Czech numbers",
            
            // 9. Data Leaks & Breaches
            "Breach Databases": "Search in leak databases (Dehashed, etc.)",
            "Paste Sites": "https://www.google.com/search?q=site:pastebin.com+\"\(cleaned)\"",
            
            // 10. Maps & Location Services
            "Google Maps": "https://www.google.com/maps/search/\(encoded)",
            "Mapy.cz": "https://mapy.cz/zakladni?q=\(encoded)",
            
            // 11. Court & Official Records
            "Justice.cz": "https://www.google.com/search?q=site:justice.cz+\"\(cleaned)\"",
            "Insolvency Register": "https://isir.justice.cz/",
            
            // 12. Spam & Scam Reporting
            "Tellows": "https://www.tellows.cz/num/\(cleaned)",
            "Who Called Me": "https://www.whocalledme.cz/",
            "Spam Phone Check": "https://www.google.com/search?q=\"\(cleaned)\"+spam+OR+scam",
            
            // 13. Dating & Social Apps
            "Tinder": "Check if phone registered on dating apps",
            "Badoo": "Social discovery platform search",
            
            // 14. Professional Networks
            "LinkedIn": "https://www.linkedin.com/search/results/all/?keywords=\(encoded)",
            
            // 15. Payment Apps
            "PayPal": "Try PayPal.me/phone lookup",
            "Venmo": "Check Venmo public profiles"
        ]
    }
}
