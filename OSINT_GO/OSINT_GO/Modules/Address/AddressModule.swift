//
//  AddressModule.swift
//  OSINT_GO
//
//  Enhanced Address OSINT Module with 10+ data sources
//

import Foundation
import SwiftUI

struct AddressModule: OsintModule {
    let name = "Address OSINT"
    let capabilities: [OsintCapability] = [.addressLookup, .geocoding, .propertyData]
    let supportedTypes: [TargetType] = [.address]
    let iconName = "mappin.and.ellipse"
    let color = Color.orange
    let description = "Comprehensive address reconnaissance with 10+ data sources"
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.5
        
        let address = target.value.trimmingCharacters(in: .whitespaces)
        details["adresa"] = address
        
        // 1. Parse address components
        let components = parseAddress(address)
        details["komponenty"] = components
        
        // 2. Geocoding - Get coordinates
        let geocodingResults = await geocodeAddress(address, context: context)
        if let coords = geocodingResults["coordinates"] {
            details["souřadnice"] = coords
            riskScore = 0.3
        }
        
        // 3. Reverse Geocoding - Validate address
        if let lat = geocodingResults["latitude"] as? Double,
           let lon = geocodingResults["longitude"] as? Double {
            let reverseResults = await reverseGeocode(lat: lat, lon: lon, context: context)
            details["zpětné_ověření"] = reverseResults
        }
        
        // 4. Generate search queries for 10+ data sources
        let searchQueries = generateSearchQueries(address: address, components: components)
        details["vyhledávací_dotazy"] = searchQueries
        
        // 5. Property database searches
        let propertySearches = generatePropertySearches(address: address)
        details["databáze_nemovitostí"] = propertySearches
        
        // 6. Cadastral and registry searches
        let registrySearches = generateRegistrySearches(address: address)
        details["katastrální_databáze"] = registrySearches
        
        // 7. Street view and imagery sources
        let imageryLinks = generateImageryLinks(address: address, coords: geocodingResults["coordinates"] as? [String: Double])
        details["obrazové_zdroje"] = imageryLinks
        
        // 8. Nearby points of interest
        details["poznámka"] = "Použijte vyhledávací dotazy k ověření adresy v různých databázích"
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Address analysis: \(address)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    // MARK: - Address Parsing
    
    private func parseAddress(_ address: String) -> [String: String] {
        var components: [String: String] = [:]
        
        // Try to detect Czech address format
        let parts = address.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if parts.count >= 1 {
            components["ulice_číslo"] = parts[0]
        }
        if parts.count >= 2 {
            components["město"] = parts[1]
        }
        if parts.count >= 3 {
            components["PSČ"] = parts[2]
        }
        
        // Extract postal code pattern
        let postalRegex = #"\d{3}\s?\d{2}"#
        if let range = address.range(of: postalRegex, options: .regularExpression) {
            components["PSČ_extrahováno"] = String(address[range])
        }
        
        // Extract street number pattern
        let numberRegex = #"\d+/?\d*"#
        if let range = address.range(of: numberRegex, options: .regularExpression) {
            components["číslo_popisné"] = String(address[range])
        }
        
        return components
    }
    
    // MARK: - Geocoding
    
    private func geocodeAddress(_ address: String, context: OsintContext) async -> [String: Any] {
        var results: [String: Any] = [:]
        
        // Use Nominatim OpenStreetMap API
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let nominatimURL = "https://nominatim.openstreetmap.org/search?format=json&q=\(encoded)&limit=1"
        
        do {
            let data = try await context.httpClient.get(nominatimURL, headers: [
                "User-Agent": "OSINT_GO/1.0"
            ])
            
            if let array = data as? [[String: Any]], let first = array.first {
                if let lat = first["lat"] as? String, let lon = first["lon"] as? String {
                    results["latitude"] = Double(lat) ?? 0.0
                    results["longitude"] = Double(lon) ?? 0.0
                    results["coordinates"] = ["lat": Double(lat) ?? 0.0, "lon": Double(lon) ?? 0.0]
                    results["display_name"] = first["display_name"] as? String ?? ""
                    results["type"] = first["type"] as? String ?? ""
                    results["importance"] = first["importance"] as? Double ?? 0.0
                }
            }
        } catch {
            results["chyba"] = "Nepodařilo se geokódovat adresu"
        }
        
        return results
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocode(lat: Double, lon: Double, context: OsintContext) async -> [String: Any] {
        var results: [String: Any] = [:]
        
        let nominatimURL = "https://nominatim.openstreetmap.org/reverse?format=json&lat=\(lat)&lon=\(lon)"
        
        do {
            let data = try await context.httpClient.get(nominatimURL, headers: [
                "User-Agent": "OSINT_GO/1.0"
            ])
            
            if let dict = data as? [String: Any] {
                results["display_name"] = dict["display_name"] as? String ?? ""
                if let address = dict["address"] as? [String: Any] {
                    results["země"] = address["country"] as? String ?? ""
                    results["město"] = address["city"] as? String ?? address["town"] as? String ?? ""
                    results["ulice"] = address["road"] as? String ?? ""
                    results["PSČ"] = address["postcode"] as? String ?? ""
                }
            }
        } catch {
            results["chyba"] = "Nepodařilo se zpětně geokódovat"
        }
        
        return results
    }
    
    // MARK: - Search Query Generation (10+ sources)
    
    private func generateSearchQueries(address: String, components: [String: String]) -> [String: String] {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            // 1. Google Maps
            "Google Maps": "https://www.google.com/maps/search/\(encoded)",
            
            // 2. OpenStreetMap
            "OpenStreetMap": "https://www.openstreetmap.org/search?query=\(encoded)",
            
            // 3. Mapy.cz (Czech maps)
            "Mapy.cz": "https://mapy.cz/zakladni?q=\(encoded)",
            
            // 4. Google Search
            "Google Vyhledávání": "https://www.google.com/search?q=\"\(encoded)\"",
            
            // 5. Bing Maps
            "Bing Maps": "https://www.bing.com/maps?q=\(encoded)",
            
            // 6. Waze
            "Waze": "https://www.waze.com/live-map/directions?q=\(encoded)",
            
            // 7. Apple Maps (search link)
            "Apple Maps": "http://maps.apple.com/?q=\(encoded)",
            
            // 8. Here Maps
            "Here Maps": "https://wego.here.com/?q=\(encoded)",
            
            // 9. What3Words (if coordinates available)
            "What3Words": "https://what3words.com/",
            
            // 10. Social media location searches
            "Facebook Places": "https://www.facebook.com/places/",
            
            // 11. Instagram location
            "Instagram Locations": "https://www.instagram.com/explore/locations/",
            
            // 12. Foursquare
            "Foursquare": "https://foursquare.com/explore?q=\(encoded)"
        ]
    }
    
    // MARK: - Property Database Searches
    
    private func generatePropertySearches(address: String) -> [String: String] {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            // 1. Sreality.cz (Czech real estate)
            "Sreality.cz": "https://www.sreality.cz/hledani/prodej/byty?q=\(encoded)",
            
            // 2. Bezrealitky.cz
            "Bezrealitky.cz": "https://www.bezrealitky.cz/vyhledat#?search=\(encoded)",
            
            // 3. RealityMix.cz
            "RealityMix.cz": "https://www.realitymix.cz/vyhledavani?search=\(encoded)",
            
            // 4. Zillow (US)
            "Zillow": "https://www.zillow.com/homes/\(encoded)_rb/",
            
            // 5. Rightmove (UK)
            "Rightmove": "https://www.rightmove.co.uk/property-for-sale/find.html?searchLocation=\(encoded)",
            
            // 6. Zoopla (UK)
            "Zoopla": "https://www.zoopla.co.uk/for-sale/property/\(encoded)/",
            
            // 7. Immobilienscout24 (DE)
            "ImmobilienScout24": "https://www.immobilienscout24.de/Suche/radius/wohnung-kaufen?geocodes=\(encoded)",
            
            // 8. Property tax records
            "Property Tax Info": "Google 'property tax records \(address)'"
        ]
    }
    
    // MARK: - Registry Searches
    
    private func generateRegistrySearches(address: String) -> [String: String] {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            // 1. Czech Cadastral Office
            "Katastr nemovitostí": "https://nahlizenidokn.cuzk.cz/",
            
            // 2. Czech Cadastral Maps
            "Katastrální mapy": "https://ags.cuzk.cz/arcgis/",
            
            // 3. Building permits
            "Stavební povolení": "Vyhledejte na webu úřadu",
            
            // 4. Land registry
            "List vlastnictví": "https://nahlizenidokn.cuzk.cz/ZobrazObjekt.aspx",
            
            // 5. Energy certificates
            "Energetické štítky": "https://www.penb.cz/",
            
            // 6. Historical records
            "Historické záznamy": "Google '\(address) historie'",
            
            // 7. Court records
            "Soudní exekuce": "https://www.ceska-justice.cz/",
            
            // 8. Public notices
            "Veřejné vyhlášky": "Google 'úřední deska \(address)'"
        ]
    }
    
    // MARK: - Imagery Links
    
    private func generateImageryLinks(address: String, coords: [String: Double]?) -> [String: String] {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var links: [String: String] = [:]
        
        // 1. Google Street View
        links["Google Street View"] = "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=\(encoded)"
        
        // 2. Mapy.cz Panorama
        links["Mapy.cz Panorama"] = "https://mapy.cz/zakladni?q=\(encoded)&source=firm"
        
        // 3. Bing Bird's Eye
        links["Bing Bird's Eye"] = "https://www.bing.com/maps?q=\(encoded)&style=h"
        
        // 4. Google Earth
        links["Google Earth"] = "https://earth.google.com/web/search/\(encoded)"
        
        // 5. Satellite imagery
        if let coords = coords, let lat = coords["lat"], let lon = coords["lon"] {
            links["Satellite View"] = "https://www.google.com/maps/@\(lat),\(lon),20z/data=!3m1!1e3"
        }
        
        // 6. Historical imagery
        links["Historical Imagery"] = "Google Earth Pro - Historical Imagery"
        
        // 7. User photos
        links["User Photos"] = "Google Maps - Photos tab"
        
        return links
    }
}
