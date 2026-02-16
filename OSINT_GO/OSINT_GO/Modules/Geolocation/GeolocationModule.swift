//
//  GeolocationModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct GeolocationModule: OsintModule {
    let name = "Advanced Geolocation"
    let capabilities: [OsintCapability] = [.advancedGeolocation]
    let supportedTypes: [TargetType] = [.ipAddress, .phone, .address, .domain]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        let targetType = TargetType(rawValue: target.type)
        
        // Generate geolocation search queries
        let queries = generateGeolocationQueries(value, type: targetType)
        details["vyhledávací_dotazy"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        details["zdroje_dat"] = """
        Geolokační data můžete získat z:
        - IP adresy (přibližná lokace dle ISP)
        - GPS souřadnic v EXIF datech fotografií
        - Telefonních předvoleb a operátorů
        - Social media check-inů
        - Wi-Fi sítí a jejich polohy
        - Časových pásem v metadatech
        """
        
        details["doporučené_nástroje"] = """
        1. IP Geolocation: MaxMind, IPinfo, IP2Location
        2. Mapy: Google Maps, OpenStreetMap, Mapillary
        3. Satellite: Google Earth, Sentinel Hub
        4. Phone: PhoneInfoga, Truecaller
        5. WiFi: WiGLE, OpenWiFi
        """
        
        details["přesnost"] = "IP geolokace je obvykle přesná na úroveň města/regionu, ne přesné adresy. Pro přesnější lokaci je potřeba GPS data nebo jiné zdroje."
        
        riskScore = 0.2
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Geolocation resources for \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateGeolocationQueries(_ value: String, type: TargetType?) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        var queries: [String: String] = [:]
        
        if type == .ipAddress {
            queries["IPinfo"] = "https://ipinfo.io/\(value)"
            queries["IP2Location"] = "https://www.ip2location.com/demo/\(value)"
            queries["MaxMind"] = "https://www.maxmind.com/en/geoip-demo"
            queries["Shodan"] = "https://www.shodan.io/host/\(value)"
        }
        
        if type == .phone {
            queries["PhoneInfoga"] = "https://www.google.com/search?q=phoneinfoga+\(encoded)"
            queries["Truecaller"] = "https://www.truecaller.com/search/\(encoded)"
        }
        
        // Universal queries
        queries["Google Maps"] = "https://www.google.com/maps/search/\(encoded)"
        queries["OpenStreetMap"] = "https://www.openstreetmap.org/search?query=\(encoded)"
        queries["Google Earth"] = "https://earth.google.com/web/search/\(encoded)"
        queries["Mapillary"] = "https://www.mapillary.com/app/?search=\(encoded)"
        
        return queries
    }
}
