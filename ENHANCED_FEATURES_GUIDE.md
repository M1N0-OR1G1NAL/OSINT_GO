# Enhanced OSINT_GO Features - Implementation Guide

## Overview

This document describes the major enhancements made to OSINT_GO to meet the requirement of having 10x recon searchers, data correlation, automated agents, and an editable GUI investigative report.

## New Modules

### 1. AddressModule
**Location**: `Modules/Address/AddressModule.swift`

**Features**:
- Geocoding with OpenStreetMap Nominatim API
- Reverse geocoding for address validation
- Address component parsing (street, city, postal code)
- 30+ data sources including:
  - Google Maps, OpenStreetMap, Mapy.cz, Bing Maps
  - Property databases (Sreality.cz, Bezrealitky, Zillow, Rightmove, etc.)
  - Cadastral databases (Czech Cadastral Office, land registry)
  - Street view and imagery sources
  - Social media location searches

**Capabilities**: `addressLookup`, `geocoding`, `propertyData`

### 2. OpenDatabasesModule
**Location**: `Modules/OpenDatabases/OpenDatabasesModule.swift`

**Features**:
- Data breach detection across 40+ sources
- Paste site searches (12+ paste sites)
- Credential dump searches
- Dark web monitoring information
- Public exposure checks (Shodan, Censys, VirusTotal, etc.)
- Safety recommendations

**Capabilities**: `breachCheck`, `credentialSearch`, `pasteSearch`

**Supported Sources**:
- Breach Databases: HaveIBeenPwned, Dehashed, Leak-Lookup, IntelligenceX, Snusbase, LeakCheck, etc.
- Paste Sites: Pastebin, Ghostbin, GitHub Gists, Rentry, etc.
- Dark Web: Ahmia, DarkSearch, Tor search engines

## Enhanced Existing Modules

### EmailModule Enhancements
- Expanded from 6 to 40+ data sources
- Added developer platforms (GitHub, GitLab, StackOverflow, CodePen)
- Added data breach databases (HIBP, Dehashed, LeakCheck, IntelligenceX)
- Added email verification services (Hunter.io, EmailRep)
- Added business platforms (Crunchbase, AngelList, Glassdoor)
- Added academic sources (Google Scholar, ResearchGate, Academia.edu)
- Added reverse email lookup services

### PhoneModule Enhancements
- Expanded from 5 to 50+ data sources
- Added reverse phone lookup (TrueCaller, Sync.me, Whoscall)
- Added Czech classifieds (Sbazar, Sreality, Bazoš, Sauto, Hyperinzerce)
- Added messaging app checks (WhatsApp, Telegram, Viber, Signal)
- Added business directories (Firmy.cz, Zlaté stránky, Yellow Pages)
- Added spam/scam reporting sites (Tellows, Who Called Me)
- Added carrier validation services

### UsernameModule Enhancements
- Expanded from 10 to 50+ platforms
- Added gaming platforms (Steam, Xbox, PlayStation, Kick)
- Added developer platforms (GitLab, Bitbucket, Dev.to, HackerRank, Kaggle)
- Added creative platforms (Behance, Dribbble, DeviantArt, ArtStation)
- Added messaging platforms (Telegram, Discord, Snapchat)
- Added professional platforms (Medium, Substack, Crunchbase, AngelList)
- Added payment platforms (Cash App, Venmo)

## Data Correlation Engine

### CorrelationEngine
**Location**: `Core/Correlation/CorrelationEngine.swift`

**Features**:
- 6 types of matching algorithms:
  1. **Exact Match**: Identical values or containment
  2. **Fuzzy Match**: Levenshtein distance similarity (80%+ threshold)
  3. **Contextual Match**: Cross-reference in module results
  4. **Geographic Match**: Proximity based on coordinates (< 20km)
  5. **Temporal Match**: Similar timestamps in creation/results
  6. **Behavioral Match**: Similar risk patterns and module coverage

**Match Confidence**:
- Each match has a confidence score (0.0 - 1.0)
- Minimum confidence threshold: 0.6
- Evidence tracking for each match
- Support for multiple evidence items per match

**Usage**:
```swift
let engine = CorrelationEngine()
let matches = engine.findMatches(targets: investigationTargets)
// Returns array of DataMatch objects with confidence scores
```

## Automated Agent Service

### AutomatedAgentService
**Location**: `Core/Agents/AutomatedAgentService.swift`

**Features**:
- Scheduled OSINT scans with 5 schedule options:
  - Hourly
  - Every 6 hours
  - Daily
  - Weekly
  - Monthly

**Agent Configuration**:
- Per-target monitoring
- Customizable module selection
- Enable/disable agents
- Notification on new findings
- Run history tracking (last 100 runs per agent)

**Agent Templates**:
1. **Social Media Monitor**: Social media + username checks every 6 hours
2. **Breach Monitor**: Email + open databases daily
3. **Reputation Tracker**: Person + company + social media weekly
4. **Domain Monitor**: Domain/DNS/WHOIS daily
5. **Comprehensive Monitor**: All email/phone/username/social daily

**Usage**:
```swift
let agentService = AutomatedAgentService()
agentService.createAgentFromTemplate(.breachMonitor, targetId: target.id)
agentService.startMonitoring()
```

## Investigative Report System

### InvestigativeReport Model
**Location**: `Features/ReportEditor/InvestigativeReport.swift`

**Structure**:
- Executive Summary
- Objectives
- Methodology
- Findings (with severity levels)
- Correlations (with confidence scores)
- Risk Assessment
- Recommendations
- Timeline
- Attachments
- Custom Sections
- Conclusions

**Report Statuses**:
- Draft (Koncept)
- Review (Ke kontrole)
- Final (Finální)
- Archived (Archivováno)

### ReportEditorView
**Location**: `Features/ReportEditor/ReportEditorView.swift`

**Features**:
- Full GUI editor for all report sections
- Editable findings with severity badges
- Editable correlations with confidence badges
- Add/remove evidence items
- Timeline visualization
- Export to PDF/HTML/JSON (placeholders)
- Auto-save on changes

**Report Generator**:
```swift
let report = ReportGenerator.generateReport(
    from: investigation,
    targets: targets,
    matches: correlatedMatches,
    author: "Investigator Name"
)
```

## New Capabilities

Added 6 new capabilities to `OsintCapability` enum:
1. `addressLookup` - Address reconnaissance
2. `geocoding` - Geographic coordinate conversion
3. `propertyData` - Property and real estate data
4. `breachCheck` - Data breach detection
5. `credentialSearch` - Credential leak searching
6. `pasteSearch` - Paste site searching

## New Playbooks

Added 3 new investigation playbooks:
1. **Address Investigation**: Address lookup, geocoding, property data
2. **Breach & Leak Monitoring**: Breach check, credential search, paste search, email validation
3. **Comprehensive Recon**: Email, phone, username, social media, address, breach checking

## Integration

### Updated Files
1. `OsintModule+Extensions.swift` - Added AddressModule and OpenDatabasesModule
2. `OsintPlaybook.swift` - Added 3 new playbooks
3. `ModulesViewModel.swift` - Added module instances
4. `OsintCapability.swift` - Added 6 new capabilities

### Module Registration
All new modules are automatically registered via `OsintModule.allModules`:
```swift
static var allModules: [OsintModule] {
    return [
        DomainIpModule(),
        DNSModule(),
        WhoisModule(),
        EmailModule(),
        UsernameModule(),
        PhoneModule(),
        CompanyModule(),
        PersonModule(),
        SocialMediaModule(),
        AddressModule(),          // NEW
        OpenDatabasesModule()     // NEW
    ]
}
```

## Statistics

### Total Data Sources by Category
- **Email**: 40+ sources
- **Phone**: 50+ sources  
- **Username**: 50+ platforms
- **Address**: 30+ sources
- **Open Databases**: 40+ sources
- **Name**: 30+ sources (PersonModule)
- **Social Media**: 25+ platforms (SocialMediaModule)
- **Domain**: 15+ sources (DomainIpModule)
- **Company**: 15+ sources (CompanyModule)

**Total**: 290+ unique OSINT data sources across all modules

## Usage Examples

### 1. Run Address Investigation
```swift
let target = Target(type: .address, value: "Václavské náměstí 1, Praha")
let playbook = OsintPlaybook.addressInvestigation
await orchestrator.runPlaybook(playbook, on: investigation)
```

### 2. Run Breach Monitoring
```swift
let target = Target(type: .email, value: "user@example.com")
let playbook = OsintPlaybook.breachMonitoring
await orchestrator.runPlaybook(playbook, on: investigation)
```

### 3. Find Data Correlations
```swift
let engine = CorrelationEngine()
let matches = engine.findMatches(targets: investigation.targets)

for match in matches {
    print("\(match.matchType.rawValue): \(match.confidence * 100)%")
    for evidence in match.evidence {
        print("  - \(evidence)")
    }
}
```

### 4. Create Automated Agent
```swift
let agentService = AutomatedAgentService()
agentService.createAgent(
    name: "Daily Email Monitor",
    targetId: emailTarget.id,
    schedule: .daily,
    modules: ["Email OSINT", "Open Databases OSINT"],
    notifyOnNewFindings: true
)
agentService.startMonitoring()
```

### 5. Generate and Edit Report
```swift
// Generate report
let report = ReportGenerator.generateReport(
    from: investigation,
    targets: targets,
    matches: correlationEngine.findMatches(targets: targets),
    author: "John Investigator"
)

// Present editor
let editorView = ReportEditorView(report: report)
// User can edit all sections, add findings, modify correlations, etc.
```

## Security & Compliance

All modules follow passive OSINT principles:
- No active scanning or exploitation
- Respect for Terms of Service
- GDPR compliance considerations
- Ethical OSINT practices
- Legal framework adherence
- Data minimization

## Future Enhancements

Potential improvements:
1. PDF export implementation with custom templates
2. HTML report generation with charts and graphs
3. Integration with commercial OSINT APIs (Maltego, Spiderfoot)
4. Machine learning for improved correlation
5. Real-time notification system
6. Cloud synchronization of reports
7. Team collaboration features
8. Encrypted report storage
9. Advanced data visualization (network graphs, heatmaps)
10. Integration with threat intelligence feeds

## Testing Recommendations

1. **Unit Tests**: Test each module independently
2. **Integration Tests**: Test correlation engine accuracy
3. **E2E Tests**: Full investigation workflow
4. **Performance Tests**: Large-scale correlation testing
5. **Security Tests**: Verify no sensitive data leakage

## Conclusion

The enhanced OSINT_GO now provides:
- ✅ 10+ data sources per recon category (290+ total)
- ✅ Advanced data correlation engine with 6 match types
- ✅ Automated monitoring agents with 5 schedule options
- ✅ Fully editable GUI investigative reports
- ✅ Cross-target matching and relationship detection
- ✅ Comprehensive breach and leak detection
- ✅ 50+ platform username checking
- ✅ Advanced address reconnaissance with geocoding

This represents a significant expansion of OSINT capabilities suitable for professional investigators.
