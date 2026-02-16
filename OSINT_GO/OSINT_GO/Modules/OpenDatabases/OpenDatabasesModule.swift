//
//  OpenDatabasesModule.swift
//  OSINT_GO
//
//  Enhanced Open Databases OSINT Module for data breach detection
//

import Foundation
import SwiftUI

struct OpenDatabasesModule: OsintModule {
    let name = "Open Databases OSINT"
    let capabilities: [OsintCapability] = [.breachCheck, .credentialSearch, .pasteSearch]
    let supportedTypes: [TargetType] = [.email, .username, .domain, .phone]
    let iconName = "externaldrive.badge.exclamationmark"
    let color = Color.red
    let description = "Search for exposed data in breaches, leaks, and paste sites (10+ sources)"
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.5
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        details["cíl"] = value
        details["typ"] = target.type.rawValue
        
        // 1. Generate search queries for 10+ breach databases
        let breachDatabases = generateBreachDatabaseSearches(value: value, type: target.type)
        details["databáze_úniků"] = breachDatabases
        
        // 2. Paste site searches
        let pasteSites = generatePasteSiteSearches(value: value)
        details["paste_weby"] = pasteSites
        
        // 3. Credential dump searches
        let credentialSearches = generateCredentialSearches(value: value)
        details["credential_dumps"] = credentialSearches
        
        // 4. Dark web monitoring (informational only)
        let darkWebInfo = generateDarkWebMonitoringInfo()
        details["dark_web_monitoring"] = darkWebInfo
        
        // 5. Public exposure checks
        let publicExposure = generatePublicExposureChecks(value: value, type: target.type)
        details["veřejná_expozice"] = publicExposure
        
        // 6. API-based breach checking (simulated)
        details["haveibeenpwned_note"] = "Pro skutečnou kontrolu použijte HaveIBeenPwned API"
        details["dehashed_note"] = "Pro hloubkovou analýzu zvažte Dehashed.com"
        details["leak_lookup_note"] = "Pro další kontrolu použijte Leak-Lookup.com"
        
        // 7. Safety recommendations
        let recommendations = generateSafetyRecommendations()
        details["doporučení"] = recommendations
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Breach database search for: \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    // MARK: - Breach Database Searches (10+ sources)
    
    private func generateBreachDatabaseSearches(value: String, type: TargetType) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var databases: [String: String] = [:]
        
        // 1. Have I Been Pwned (email)
        if type == .email {
            databases["HaveIBeenPwned"] = "https://haveibeenpwned.com/account/\(encoded)"
        }
        
        // 2. Dehashed (comprehensive)
        databases["Dehashed"] = "https://dehashed.com/search?query=\(encoded)"
        
        // 3. Leak-Lookup
        databases["Leak-Lookup"] = "https://leak-lookup.com/search?query=\(encoded)"
        
        // 4. IntelligenceX
        databases["IntelligenceX"] = "https://intelx.io/?s=\(encoded)"
        
        // 5. Snusbase
        databases["Snusbase"] = "https://snusbase.com/ (Search: \(value))"
        
        // 6. LeakCheck
        databases["LeakCheck"] = "https://leakcheck.io/search?query=\(encoded)"
        
        // 7. WeLeakInfo (discontinued but archives exist)
        databases["WeLeakInfo Archives"] = "Search for WeLeakInfo mirrors/archives"
        
        // 8. Hudson Rock Cybercrime Intelligence
        databases["Hudson Rock"] = "https://cavalier.hudsonrock.com/search/\(encoded)"
        
        // 9. Scylla.sh
        databases["Scylla"] = "https://scylla.sh/search?q=\(encoded)"
        
        // 10. BreachDirectory
        databases["BreachDirectory"] = "https://breachdirectory.org/search?q=\(encoded)"
        
        // 11. GhostProject
        databases["GhostProject"] = "https://ghostproject.fr/"
        
        // 12. Leaked Source
        databases["LeakedSource"] = "Search for LeakedSource mirrors (discontinued)"
        
        return databases
    }
    
    // MARK: - Paste Site Searches
    
    private func generatePasteSiteSearches(value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            // 1. Pastebin
            "Pastebin": "https://pastebin.com/search?q=\(encoded)",
            
            // 2. Ghostbin
            "Ghostbin": "https://ghostbin.com/search?q=\(encoded)",
            
            // 3. Slexy
            "Slexy": "https://slexy.org/search?q=\(encoded)",
            
            // 4. PasteBin.pl
            "PasteBin.pl": "https://pastebin.pl/search?q=\(encoded)",
            
            // 5. Rentry
            "Rentry": "https://rentry.co/search?q=\(encoded)",
            
            // 6. Justpaste.it
            "Justpaste.it": "https://justpaste.it/search?q=\(encoded)",
            
            // 7. Hastebin
            "Hastebin": "Search Hastebin archives",
            
            // 8. GitHub Gists
            "GitHub Gists": "https://gist.github.com/search?q=\(encoded)",
            
            // 9. GitLab Snippets
            "GitLab Snippets": "https://gitlab.com/explore/snippets?search=\(encoded)",
            
            // 10. Paste.ee
            "Paste.ee": "https://paste.ee/search?q=\(encoded)",
            
            // 11. ControlC
            "ControlC": "https://controlc.com/search?q=\(encoded)",
            
            // 12. Dpaste
            "Dpaste": "https://dpaste.com/search?q=\(encoded)"
        ]
    }
    
    // MARK: - Credential Dump Searches
    
    private func generateCredentialSearches(value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            // 1. Google Dorks for credentials
            "Google Dork - Passwords": "https://www.google.com/search?q=\"\(encoded)\"+password+OR+credentials",
            
            // 2. Google Dork - Config files
            "Google Dork - Config": "https://www.google.com/search?q=\"\(encoded)\"+ext:sql+OR+ext:env+OR+ext:config",
            
            // 3. Google Dork - Database dumps
            "Google Dork - DB Dumps": "https://www.google.com/search?q=\"\(encoded)\"+site:*.sql",
            
            // 4. GitHub code search
            "GitHub Code Search": "https://github.com/search?q=\"\(encoded)\"+password&type=code",
            
            // 5. GitLab code search
            "GitLab Code Search": "https://gitlab.com/search?search=\"\(encoded)\"&group_id=&project_id=&scope=blobs",
            
            // 6. Pastebin credential leaks
            "Pastebin Credentials": "https://www.google.com/search?q=site:pastebin.com+\"\(encoded)\"+password",
            
            // 7. Reddit credential discussions
            "Reddit Breach Discussions": "https://www.reddit.com/search/?q=\(encoded)+breach+OR+leak",
            
            // 8. Twitter breach announcements
            "Twitter Breach News": "https://twitter.com/search?q=\(encoded)+breach+OR+leak&src=typed_query",
            
            // 9. Dark web search engines (Ahmia - Tor)
            "Ahmia (Tor)": "https://ahmia.fi/search/?q=\(encoded)",
            
            // 10. Credential stuffing databases
            "Credential Stuffing DBs": "Contacte OSINT profesionály pro přístup"
        ]
    }
    
    // MARK: - Dark Web Monitoring Info
    
    private func generateDarkWebMonitoringInfo() -> [String: String] {
        return [
            "Ahmia": "Tor search engine - https://ahmia.fi/",
            "Torch": "Tor search engine (onion link required)",
            "DarkSearch": "https://darksearch.io/",
            "Haystak": "Tor search engine",
            "OnionLand": "Tor directory",
            "Note": "Vyžaduje Tor Browser a znalost bezpečnostních praktik",
            "Warning": "Přístup k dark webu může být nezákonný v některých jurisdikcích",
            "Recommendation": "Použijte profesionální služby jako Recorded Future, Flashpoint, nebo Digital Shadows"
        ]
    }
    
    // MARK: - Public Exposure Checks
    
    private func generatePublicExposureChecks(value: String, type: TargetType) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var checks: [String: String] = [:]
        
        // 1. Shodan (if domain/IP)
        if type == .domain || type == .ip {
            checks["Shodan"] = "https://www.shodan.io/search?query=\(encoded)"
        }
        
        // 2. Censys (if domain/IP)
        if type == .domain || type == .ip {
            checks["Censys"] = "https://search.censys.io/search?q=\(encoded)"
        }
        
        // 3. VirusTotal
        if type == .domain || type == .email {
            checks["VirusTotal"] = "https://www.virustotal.com/gui/search/\(encoded)"
        }
        
        // 4. URLScan
        if type == .domain {
            checks["URLScan"] = "https://urlscan.io/search/#\(encoded)"
        }
        
        // 5. Wayback Machine
        checks["Wayback Machine"] = "https://web.archive.org/web/*/\(encoded)"
        
        // 6. PublicWWW (source code search)
        checks["PublicWWW"] = "https://publicwww.com/websites/\"\(encoded)\""
        
        // 7. SecurityTrails
        if type == .domain {
            checks["SecurityTrails"] = "https://securitytrails.com/domain/\(encoded)/dns"
        }
        
        // 8. Pulsedive
        checks["Pulsedive"] = "https://pulsedive.com/search/?q=\(encoded)"
        
        // 9. ThreatCrowd
        if type == .domain || type == .email {
            checks["ThreatCrowd"] = "https://www.threatcrowd.org/searchApi/v2/email/report/?email=\(encoded)"
        }
        
        // 10. AlienVault OTX
        checks["AlienVault OTX"] = "https://otx.alienvault.com/browse/global/pulses?q=\(encoded)"
        
        return checks
    }
    
    // MARK: - Safety Recommendations
    
    private func generateSafetyRecommendations() -> [String] {
        return [
            "Pokud byla data nalezena v úniku, okamžitě změňte hesla",
            "Aktivujte dvoufaktorovou autentifikaci (2FA) na všech účtech",
            "Použijte unikátní hesla pro každý účet (password manager)",
            "Pravidelně kontrolujte své účty na HaveIBeenPwned.com",
            "Zvažte zmrazení kreditních zpráv pokud byly odhaleny osobní údaje",
            "Monitorujte bankovní výpisy a kreditní karty",
            "Nastavte upozornění na podezřelou aktivitu",
            "Zvažte služby monitoringu identity pro dlouhodobou ochranu",
            "Nepoužívejte stejné heslo na více místech",
            "Buďte ostražití vůči phishingovým pokusům po úniku dat",
            "Kontaktujte poskytovatele služeb pokud byl váš účet kompromitován",
            "Dokumentujte všechny zjištěné úniky pro případné právní kroky"
        ]
    }
}
