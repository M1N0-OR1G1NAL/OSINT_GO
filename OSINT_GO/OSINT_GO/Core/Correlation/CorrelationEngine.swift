//
//  CorrelationEngine.swift
//  OSINT_GO
//
//  Data correlation and matching engine for OSINT investigations
//

import Foundation

/// Represents a match between two targets
struct DataMatch: Identifiable {
    let id = UUID()
    let target1: Target
    let target2: Target
    let matchType: MatchType
    let confidence: Double // 0.0 - 1.0
    let evidence: [String]
    let timestamp: Date
    
    enum MatchType: String {
        case exact = "Přesná shoda"
        case fuzzy = "Podobnost"
        case contextual = "Kontextová souvislost"
        case geographic = "Geografická blízkost"
        case temporal = "Časová souvislost"
        case behavioral = "Behaviorální vzor"
    }
}

/// Correlation engine for finding matches between targets
class CorrelationEngine {
    
    // MARK: - Configuration
    
    private let minConfidence: Double = 0.6
    private let fuzzyMatchThreshold: Double = 0.8
    
    // MARK: - Main Correlation Function
    
    /// Find all matches between targets in an investigation
    func findMatches(targets: [Target]) -> [DataMatch] {
        var matches: [DataMatch] = []
        
        // Compare each target with every other target
        for i in 0..<targets.count {
            for j in (i+1)..<targets.count {
                let target1 = targets[i]
                let target2 = targets[j]
                
                // Find all types of matches between these two targets
                matches.append(contentsOf: findMatchesBetween(target1, target2))
            }
        }
        
        // Filter by minimum confidence
        return matches.filter { $0.confidence >= minConfidence }
    }
    
    // MARK: - Pairwise Matching
    
    private func findMatchesBetween(_ target1: Target, _ target2: Target) -> [DataMatch] {
        var matches: [DataMatch] = []
        
        // 1. Check for exact value matches
        if let exactMatch = checkExactMatch(target1, target2) {
            matches.append(exactMatch)
        }
        
        // 2. Check for fuzzy string matches (names, addresses)
        if let fuzzyMatch = checkFuzzyMatch(target1, target2) {
            matches.append(fuzzyMatch)
        }
        
        // 3. Check for contextual matches in results
        if let contextMatch = checkContextualMatch(target1, target2) {
            matches.append(contextMatch)
        }
        
        // 4. Check for geographic proximity
        if let geoMatch = checkGeographicMatch(target1, target2) {
            matches.append(geoMatch)
        }
        
        // 5. Check for temporal correlation
        if let temporalMatch = checkTemporalMatch(target1, target2) {
            matches.append(temporalMatch)
        }
        
        // 6. Check for behavioral patterns
        if let behavioralMatch = checkBehavioralMatch(target1, target2) {
            matches.append(behavioralMatch)
        }
        
        return matches
    }
    
    // MARK: - Match Type Implementations
    
    /// Check for exact value matches
    private func checkExactMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        // Normalize values for comparison
        let value1 = target1.value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let value2 = target2.value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if value1 == value2 {
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .exact,
                confidence: 1.0,
                evidence: ["Identické hodnoty: \(target1.value)"],
                timestamp: Date()
            )
        }
        
        // Check if one value contains the other (e.g., email contains username)
        if value1.contains(value2) || value2.contains(value1) {
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .exact,
                confidence: 0.9,
                evidence: ["Hodnota obsažena v druhé: \(target1.value) ↔ \(target2.value)"],
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    /// Check for fuzzy string matches (Levenshtein distance)
    private func checkFuzzyMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        // Only apply fuzzy matching to name and address types
        guard target1.type == .personName || target1.type == .address ||
              target2.type == .personName || target2.type == .address else {
            return nil
        }
        
        let similarity = calculateStringSimilarity(target1.value, target2.value)
        
        if similarity >= fuzzyMatchThreshold {
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .fuzzy,
                confidence: similarity,
                evidence: ["Podobnost řetězců: \(Int(similarity * 100))%"],
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    /// Check for contextual matches in module results
    private func checkContextualMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        var evidence: [String] = []
        var matchCount = 0
        
        // Check if target1's value appears in target2's results
        for result in target2.results {
            if let details = result.details as? [String: Any] {
                let detailsString = String(describing: details).lowercased()
                if detailsString.contains(target1.value.lowercased()) {
                    evidence.append("'\(target1.value)' nalezeno v \(result.moduleName) výsledcích cíle '\(target2.value)'")
                    matchCount += 1
                }
            }
        }
        
        // Check if target2's value appears in target1's results
        for result in target1.results {
            if let details = result.details as? [String: Any] {
                let detailsString = String(describing: details).lowercased()
                if detailsString.contains(target2.value.lowercased()) {
                    evidence.append("'\(target2.value)' nalezeno v \(result.moduleName) výsledcích cíle '\(target1.value)'")
                    matchCount += 1
                }
            }
        }
        
        if matchCount > 0 {
            let confidence = min(0.7 + (Double(matchCount) * 0.1), 1.0)
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .contextual,
                confidence: confidence,
                evidence: evidence,
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    /// Check for geographic proximity (addresses with coordinates)
    private func checkGeographicMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        // Extract coordinates from address results
        guard let coords1 = extractCoordinates(from: target1),
              let coords2 = extractCoordinates(from: target2) else {
            return nil
        }
        
        let distance = calculateDistance(
            lat1: coords1.latitude,
            lon1: coords1.longitude,
            lat2: coords2.latitude,
            lon2: coords2.longitude
        )
        
        // Consider proximity based on distance
        var confidence = 0.0
        var proximityDesc = ""
        
        if distance < 0.1 { // < 100m
            confidence = 0.95
            proximityDesc = "Velmi blízko (< 100m)"
        } else if distance < 1.0 { // < 1km
            confidence = 0.85
            proximityDesc = "Blízko (< 1km)"
        } else if distance < 5.0 { // < 5km
            confidence = 0.75
            proximityDesc = "V okolí (< 5km)"
        } else if distance < 20.0 { // < 20km
            confidence = 0.65
            proximityDesc = "Ve stejné oblasti (< 20km)"
        } else {
            return nil
        }
        
        return DataMatch(
            target1: target1,
            target2: target2,
            matchType: .geographic,
            confidence: confidence,
            evidence: [
                "\(proximityDesc): \(String(format: "%.2f", distance)) km",
                "Souřadnice 1: \(coords1.latitude), \(coords1.longitude)",
                "Souřadnice 2: \(coords2.latitude), \(coords2.longitude)"
            ],
            timestamp: Date()
        )
    }
    
    /// Check for temporal correlation (similar timestamps)
    private func checkTemporalMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        // Compare creation timestamps
        let timeDiff = abs(target1.createdAt.timeIntervalSince(target2.createdAt))
        
        // Check if targets were created within similar timeframes
        if timeDiff < 3600 { // Within 1 hour
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .temporal,
                confidence: 0.7,
                evidence: ["Cíle vytvořeny krátce po sobě (< 1 hodina)"],
                timestamp: Date()
            )
        }
        
        // Check for patterns in result timestamps
        var evidence: [String] = []
        
        for r1 in target1.results {
            for r2 in target2.results {
                let resultDiff = abs(r1.timestamp.timeIntervalSince(r2.timestamp))
                if resultDiff < 300 { // Within 5 minutes
                    evidence.append("Výsledky nalezeny současně: \(r1.moduleName) a \(r2.moduleName)")
                }
            }
        }
        
        if !evidence.isEmpty {
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .temporal,
                confidence: 0.65,
                evidence: evidence,
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    /// Check for behavioral patterns
    private func checkBehavioralMatch(_ target1: Target, _ target2: Target) -> DataMatch? {
        var evidence: [String] = []
        var patternScore = 0.0
        
        // 1. Similar risk scores across modules
        let risk1 = target1.results.map { $0.riskScore }
        let risk2 = target2.results.map { $0.riskScore }
        
        if !risk1.isEmpty && !risk2.isEmpty {
            let avgRisk1 = risk1.reduce(0, +) / Double(risk1.count)
            let avgRisk2 = risk2.reduce(0, +) / Double(risk2.count)
            
            let riskDiff = abs(avgRisk1 - avgRisk2)
            if riskDiff < 0.2 {
                evidence.append("Podobná úroveň rizika: \(Int(avgRisk1 * 100))% vs \(Int(avgRisk2 * 100))%")
                patternScore += 0.3
            }
        }
        
        // 2. Similar module coverage (same types of recon performed)
        let modules1 = Set(target1.results.map { $0.moduleName })
        let modules2 = Set(target2.results.map { $0.moduleName })
        let commonModules = modules1.intersection(modules2)
        
        if !commonModules.isEmpty {
            let coverage = Double(commonModules.count) / Double(max(modules1.count, modules2.count))
            if coverage > 0.5 {
                evidence.append("Podobný rozsah vyšetřování: \(commonModules.count) společných modulů")
                patternScore += coverage * 0.4
            }
        }
        
        // 3. Similar result patterns (e.g., both have social media presence)
        var patternMatches = 0
        
        for r1 in target1.results {
            for r2 in target2.results {
                if r1.moduleName == r2.moduleName {
                    // Check for similar result structures
                    if let d1 = r1.details as? [String: Any],
                       let d2 = r2.details as? [String: Any] {
                        let keys1 = Set(d1.keys)
                        let keys2 = Set(d2.keys)
                        let commonKeys = keys1.intersection(keys2)
                        
                        if Double(commonKeys.count) / Double(max(keys1.count, keys2.count)) > 0.7 {
                            patternMatches += 1
                        }
                    }
                }
            }
        }
        
        if patternMatches > 0 {
            evidence.append("Podobné vzory v \(patternMatches) modulech")
            patternScore += min(Double(patternMatches) * 0.1, 0.3)
        }
        
        if patternScore >= 0.6 {
            return DataMatch(
                target1: target1,
                target2: target2,
                matchType: .behavioral,
                confidence: min(patternScore, 1.0),
                evidence: evidence,
                timestamp: Date()
            )
        }
        
        return nil
    }
    
    // MARK: - Helper Functions
    
    /// Calculate string similarity using Levenshtein distance
    private func calculateStringSimilarity(_ str1: String, _ str2: String) -> Double {
        let s1 = str1.lowercased()
        let s2 = str2.lowercased()
        
        // Prevent excessive memory usage for very long strings
        let maxLength = 1000
        if s1.count > maxLength || s2.count > maxLength {
            // For very long strings, use a simple containment check
            if s1.contains(s2) || s2.contains(s1) {
                return 0.8
            }
            return 0.0
        }
        
        let distance = levenshteinDistance(s1, s2)
        let maxLengthValue = Double(max(s1.count, s2.count))
        
        if maxLengthValue == 0 {
            return 1.0
        }
        
        return 1.0 - (Double(distance) / maxLengthValue)
    }
    
    /// Levenshtein distance algorithm
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let a = Array(str1)
        let b = Array(str2)
        
        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count {
            dist[i][0] = i
        }
        
        for j in 0...b.count {
            dist[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i-1] == b[j-1] ? 0 : 1
                dist[i][j] = min(
                    dist[i-1][j] + 1,
                    dist[i][j-1] + 1,
                    dist[i-1][j-1] + cost
                )
            }
        }
        
        return dist[a.count][b.count]
    }
    
    /// Extract coordinates from target results
    private func extractCoordinates(from target: Target) -> (latitude: Double, longitude: Double)? {
        for result in target.results {
            if let details = result.details as? [String: Any] {
                // Check for various coordinate formats
                if let lat = details["latitude"] as? Double,
                   let lon = details["longitude"] as? Double {
                    return (lat, lon)
                }
                
                if let coords = details["souřadnice"] as? [String: Double],
                   let lat = coords["lat"],
                   let lon = coords["lon"] {
                    return (lat, lon)
                }
            }
        }
        return nil
    }
    
    /// Calculate distance between two coordinates (Haversine formula)
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // km
        
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
}
