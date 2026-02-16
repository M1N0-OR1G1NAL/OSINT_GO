//
//  InvestigativeReport.swift
//  OSINT_GO
//
//  Editable investigative report model
//

import Foundation
import SwiftUI

/// Comprehensive investigative report
struct InvestigativeReport: Identifiable, Codable {
    let id: UUID
    var title: String
    var investigationId: UUID
    var createdAt: Date
    var updatedAt: Date
    var author: String
    var status: ReportStatus
    
    // Report sections
    var executiveSummary: String
    var objectives: String
    var methodology: String
    var findings: [ReportFinding]
    var correlations: [CorrelationFinding]
    var riskAssessment: RiskAssessment
    var recommendations: [String]
    var timeline: [TimelineEvent]
    var attachments: [ReportAttachment]
    var customSections: [CustomSection]
    var conclusions: String
    
    enum ReportStatus: String, Codable {
        case draft = "Koncept"
        case review = "Ke kontrole"
        case final = "Finální"
        case archived = "Archivováno"
    }
    
    init(investigationId: UUID, title: String, author: String) {
        self.id = UUID()
        self.investigationId = investigationId
        self.title = title
        self.author = author
        self.createdAt = Date()
        self.updatedAt = Date()
        self.status = .draft
        self.executiveSummary = ""
        self.objectives = ""
        self.methodology = ""
        self.findings = []
        self.correlations = []
        self.riskAssessment = RiskAssessment()
        self.recommendations = []
        self.timeline = []
        self.attachments = []
        self.customSections = []
        self.conclusions = ""
    }
}

/// Individual finding in the report
struct ReportFinding: Identifiable, Codable {
    let id: UUID
    var category: String
    var title: String
    var description: String
    var evidence: [String]
    var severity: Severity
    var verified: Bool
    var notes: String
    
    enum Severity: String, Codable, CaseIterable {
        case critical = "Kritické"
        case high = "Vysoké"
        case medium = "Střední"
        case low = "Nízké"
        case info = "Informativní"
        
        var color: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .yellow
            case .low: return .blue
            case .info: return .gray
            }
        }
    }
    
    init(category: String, title: String, description: String = "", severity: Severity = .info) {
        self.id = UUID()
        self.category = category
        self.title = title
        self.description = description
        self.evidence = []
        self.severity = severity
        self.verified = false
        self.notes = ""
    }
}

/// Correlation finding between targets
struct CorrelationFinding: Identifiable, Codable {
    let id: UUID
    var target1Name: String
    var target2Name: String
    var matchType: String
    var confidence: Double
    var description: String
    var evidence: [String]
    var investigatorNotes: String
    
    init(target1: String, target2: String, matchType: String, confidence: Double) {
        self.id = UUID()
        self.target1Name = target1
        self.target2Name = target2
        self.matchType = matchType
        self.confidence = confidence
        self.description = ""
        self.evidence = []
        self.investigatorNotes = ""
    }
}

/// Risk assessment section
struct RiskAssessment: Codable {
    var overallRisk: RiskLevel
    var categories: [RiskCategory]
    var mitigationStrategies: [String]
    var notes: String
    
    enum RiskLevel: String, Codable, CaseIterable {
        case minimal = "Minimální"
        case low = "Nízké"
        case moderate = "Střední"
        case high = "Vysoké"
        case critical = "Kritické"
        
        var color: Color {
            switch self {
            case .minimal: return .green
            case .low: return .blue
            case .moderate: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
    
    init() {
        self.overallRisk = .moderate
        self.categories = []
        self.mitigationStrategies = []
        self.notes = ""
    }
}

struct RiskCategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var level: RiskAssessment.RiskLevel
    var description: String
    
    init(name: String, level: RiskAssessment.RiskLevel, description: String = "") {
        self.id = UUID()
        self.name = name
        self.level = level
        self.description = description
    }
}

/// Timeline event
struct TimelineEvent: Identifiable, Codable {
    let id: UUID
    var date: Date
    var title: String
    var description: String
    var category: String
    var relatedTargets: [String]
    
    init(date: Date, title: String, description: String = "", category: String = "General") {
        self.id = UUID()
        self.date = date
        self.title = title
        self.description = description
        self.category = category
        self.relatedTargets = []
    }
}

/// Report attachment
struct ReportAttachment: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: AttachmentType
    var path: String
    var addedAt: Date
    var description: String
    
    enum AttachmentType: String, Codable {
        case screenshot = "Screenshot"
        case document = "Dokument"
        case exportedData = "Exportovaná data"
        case other = "Jiné"
    }
    
    init(name: String, type: AttachmentType, path: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.path = path
        self.addedAt = Date()
        self.description = ""
    }
}

/// Custom section in report
struct CustomSection: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var order: Int
    
    init(title: String, content: String = "", order: Int = 0) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.order = order
    }
}

// MARK: - Report Generator

class ReportGenerator {
    
    /// Generate report from investigation
    static func generateReport(
        from investigation: Investigation,
        targets: [Target],
        matches: [DataMatch],
        author: String
    ) -> InvestigativeReport {
        
        var report = InvestigativeReport(
            investigationId: investigation.id,
            title: "Investigative Report: \(investigation.name)",
            author: author
        )
        
        // 1. Generate Executive Summary
        report.executiveSummary = generateExecutiveSummary(investigation, targets)
        
        // 2. Set Objectives
        report.objectives = "Cíle vyšetřování:\n- Identifikace a ověření cílů\n- Sběr relevantních dat\n- Analýza souvislostí"
        
        // 3. Set Methodology
        report.methodology = generateMethodology(targets)
        
        // 4. Extract Findings from module results
        report.findings = extractFindings(from: targets)
        
        // 5. Add Correlations
        report.correlations = convertMatchesToFindings(matches)
        
        // 6. Calculate Risk Assessment
        report.riskAssessment = calculateRiskAssessment(targets)
        
        // 7. Generate Timeline
        report.timeline = generateTimeline(targets)
        
        // 8. Generate Recommendations
        report.recommendations = generateRecommendations(targets, matches)
        
        // 9. Conclusions
        report.conclusions = generateConclusions(investigation, targets, matches)
        
        return report
    }
    
    private static func generateExecutiveSummary(_ investigation: Investigation, _ targets: [Target]) -> String {
        let targetCount = targets.count
        let moduleCount = targets.flatMap { $0.results }.count
        
        return """
        Toto vyšetřování '\(investigation.name)' analyzovalo \(targetCount) cílů pomocí \(moduleCount) OSINT modulů.
        
        Vyšetřování bylo zahájeno \(formatDate(investigation.createdAt)) a zahrnovalo komplexní analýzu různých zdrojů dat.
        
        Klíčová zjištění a korelace jsou detailně popsány v následujících sekcích.
        """
    }
    
    private static func generateMethodology(_ targets: [Target]) -> String {
        let modules = Set(targets.flatMap { $0.results }.map { $0.moduleName })
        
        var methodology = "Použité OSINT moduly:\n"
        for module in modules.sorted() {
            methodology += "- \(module)\n"
        }
        
        methodology += "\nPřístup:\n"
        methodology += "- Pasivní OSINT metody\n"
        methodology += "- Paralelní sběr dat z veřejných zdrojů\n"
        methodology += "- Automatická korelace výsledků\n"
        methodology += "- Ověření nálezů z více zdrojů\n"
        
        return methodology
    }
    
    private static func extractFindings(from targets: [Target]) -> [ReportFinding] {
        var findings: [ReportFinding] = []
        
        for target in targets {
            for result in target.results {
                let severity: ReportFinding.Severity
                if result.riskScore > 0.8 {
                    severity = .critical
                } else if result.riskScore > 0.6 {
                    severity = .high
                } else if result.riskScore > 0.4 {
                    severity = .medium
                } else if result.riskScore > 0.2 {
                    severity = .low
                } else {
                    severity = .info
                }
                
                var finding = ReportFinding(
                    category: result.moduleName,
                    title: "Nález pro \(target.value)",
                    description: result.summary,
                    severity: severity
                )
                
                finding.evidence = extractEvidenceFromDetails(result.details)
                findings.append(finding)
            }
        }
        
        return findings
    }
    
    private static func extractEvidenceFromDetails(_ details: [String: Any]) -> [String] {
        var evidence: [String] = []
        
        for (key, value) in details {
            if let stringValue = value as? String {
                evidence.append("\(key): \(stringValue)")
            } else if let dictValue = value as? [String: Any] {
                evidence.append("\(key): \(dictValue.count) položek")
            } else if let arrayValue = value as? [Any] {
                evidence.append("\(key): \(arrayValue.count) záznamů")
            }
        }
        
        return evidence
    }
    
    private static func convertMatchesToFindings(_ matches: [DataMatch]) -> [CorrelationFinding] {
        return matches.map { match in
            var finding = CorrelationFinding(
                target1: match.target1.value,
                target2: match.target2.value,
                matchType: match.matchType.rawValue,
                confidence: match.confidence
            )
            finding.evidence = match.evidence
            return finding
        }
    }
    
    private static func calculateRiskAssessment(_ targets: [Target]) -> RiskAssessment {
        var assessment = RiskAssessment()
        
        let allRiskScores = targets.flatMap { $0.results }.map { $0.riskScore }
        let avgRisk = allRiskScores.isEmpty ? 0.0 : allRiskScores.reduce(0, +) / Double(allRiskScores.count)
        
        if avgRisk > 0.8 {
            assessment.overallRisk = .critical
        } else if avgRisk > 0.6 {
            assessment.overallRisk = .high
        } else if avgRisk > 0.4 {
            assessment.overallRisk = .moderate
        } else if avgRisk > 0.2 {
            assessment.overallRisk = .low
        } else {
            assessment.overallRisk = .minimal
        }
        
        return assessment
    }
    
    private static func generateTimeline(_ targets: [Target]) -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        
        // Add target creation events
        for target in targets {
            events.append(TimelineEvent(
                date: target.createdAt,
                title: "Cíl přidán",
                description: "\(target.type.rawValue): \(target.value)",
                category: "Target"
            ))
        }
        
        // Add result events
        for target in targets {
            for result in target.results {
                events.append(TimelineEvent(
                    date: result.timestamp,
                    title: result.moduleName,
                    description: result.summary,
                    category: "Finding"
                ))
            }
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    private static func generateRecommendations(_ targets: [Target], _ matches: [DataMatch]) -> [String] {
        var recommendations: [String] = []
        
        recommendations.append("Pravidelně aktualizujte vyšetřování novými zdroji dat")
        recommendations.append("Ověřte všechny nálezy s vysokou úrovní rizika")
        
        if !matches.isEmpty {
            recommendations.append("Prozkoumejte identifikované korelace mezi cíli")
        }
        
        recommendations.append("Archivujte důležité dokumenty a screenshoty")
        recommendations.append("Zajistěte dodržování GDPR a dalších relevantních předpisů")
        
        return recommendations
    }
    
    private static func generateConclusions(_ investigation: Investigation, _ targets: [Target], _ matches: [DataMatch]) -> String {
        return """
        Vyšetřování bylo úspěšně dokončeno s \(targets.count) analyzovanými cíli.
        
        Identifikováno bylo \(matches.count) korelací mezi daty.
        
        Všechny nálezy byly zdokumentovány a doporučení jsou k dispozici výše.
        
        Doporučujeme pravidelný monitoring a aktualizaci vyšetřování.
        """
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter
    }()
    
    private static func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
