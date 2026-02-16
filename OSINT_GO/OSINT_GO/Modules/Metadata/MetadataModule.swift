//
//  MetadataModule.swift
//  OSINT_GO
//
//  Created by GitHub Copilot on 16.02.2026.
//


import Foundation

struct MetadataModule: OsintModule {
    let name = "Metadata Extraction"
    let capabilities: [OsintCapability] = [.metadataExtraction]
    let supportedTypes: [TargetType] = [.url, .document]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        
        // Information about metadata extraction
        details["typy_metadat"] = """
        Běžné typy metadat:
        - EXIF (fotografie): GPS souřadnice, datum, zařízení, autor
        - PDF: autor, datum vytvoření, software, revize
        - Office dokumenty: autor, společnost, počítač, časové údaje
        - Video: kodek, rozlišení, GPS, doba natáčení
        """
        
        details["doporučené_nástroje"] = """
        Pro extrakci metadat doporučujeme:
        1. ExifTool - univerzální nástroj
        2. FOCA - metadata z Office dokumentů
        3. Metagoofil - metadata z webů
        4. Jeffrey's Image Metadata Viewer (online)
        5. Pic2Map - GPS z EXIF dat
        """
        
        let queries = generateMetadataQueries(value)
        details["online_nástroje"] = queries
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        details["upozornění"] = """
        Metadata mohou obsahovat citlivé informace:
        - Přesnou polohu místa pořízení
        - Jméno autora nebo společnosti
        - Datum a čas vytvoření
        - Informace o zařízení nebo softwaru
        """
        
        riskScore = 0.4
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Metadata extraction tools for \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateMetadataQueries(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        
        return [
            "Jeffrey's EXIF Viewer": "https://exif.regex.info/exif.cgi",
            "Pic2Map": "https://www.pic2map.com/",
            "Metadata2Go": "https://www.metadata2go.com/",
            "FotoForensics": "https://fotoforensics.com/",
            "Google (filetype)": "https://www.google.com/search?q=site:\(encoded)+filetype:pdf+OR+filetype:doc+OR+filetype:xls",
            "VirusTotal": "https://www.virustotal.com/gui/url/\(encoded)/details"
        ]
    }
}
