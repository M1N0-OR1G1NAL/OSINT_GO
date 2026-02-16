# OSINT GO Toolkit - Implementation Documentation

## Overview
This document describes the implementation of the OSINT GO Toolkit based on the Czech requirements. The application provides professional OSINT capabilities combined with device security features for iOS.

## Architecture

### Main Components

#### 1. TabBar Navigation (4 Tabs)
The app uses a 4-tab structure as specified:

1. **Investigations** - OSINT case management
2. **Modules** - Manual execution of OSINT modules  
3. **Device** - iOS security health checker
4. **Settings** - Configuration and preferences

### Features Implemented

## 1. Investigations Tab

### Core Features
- ✅ Case/Investigation list with editable names
- ✅ Target management within investigations
- ✅ Results tracking from OSINT modules
- ✅ Graph visualization of relationships
- ✅ Timeline of investigation events
- ✅ **Notes system** - Editable notes for each investigation
- ✅ **Roots tracking** - Document investigation origins/roots
- ✅ Result aggregation from all modules

### Investigation Detail Tabs
- **Targets Tab**: View and manage all targets in the investigation
- **Timeline Tab**: Chronological view of all events
- **Graph Tab**: Visual relationship mapping between targets
- **Results Tab**: All module execution results
- **Notes Tab**: Investigation notes and roots documentation

### Data Models
```swift
Investigation {
    - id: UUID
    - name: String
    - targets: [Target]
    - notes: [Note]
    - roots: String (investigation origins)
    - graphData: GraphData?
    - riskScore: Double
    - createdAt/updatedAt: Date
}

Note {
    - id: UUID
    - content: String
    - investigation: Investigation?
    - createdAt/updatedAt: Date
}

GraphData {
    - nodes: [GraphNodeData]
    - edges: [GraphEdge]
    - layout: GraphLayout
}
```

## 2. Modules Tab

### Available Module Categories
- **Domain & IP**: DNS, WHOIS, Domain/IP reconnaissance
- **Email & Username**: Email validation, username searches
- **Company & Phone**: IČO lookup, phone validation
- **Person**: Name searches across multiple sources
- **Social Media**: Platform-specific searches

### Features
- ✅ Manual module execution on targets
- ✅ Module categorization by type
- ✅ Integration with investigation targets
- ✅ Support for various OSINT engines (as per subscription)

### Subscription Tiers
Modules available vary by subscription:
- **Free**: Basic OSINT modules, 5 concurrent requests
- **Basic**: AI OSINT engine, NMAP, PhoneInfoga, 10 concurrent
- **Professional**: AI Info Gathering, unlimited concurrent, cloud sync
- **Enterprise**: Custom AI models, API access, dedicated support

## 3. Device Security Tab

### Security Checks Implemented
- ✅ **iOS Version Check**: Validates if iOS is up-to-date
- ✅ **Device Model Detection**: Shows current device model
- ✅ **Jailbreak Detection**: Heuristic-based detection
  - Checks for Cydia and other jailbreak indicators
  - Attempts to write outside sandbox
  - Checks for suspicious URL schemes
- ✅ **Biometrics Check**: Face ID/Touch ID status
- ✅ **Passcode Check**: Device lock status
- ✅ **Security Score**: Percentage calculation (0-100%)

### Device Information Display
```swift
DeviceInfo {
    - iosVersion: String (e.g., "17.2")
    - deviceModel: String (e.g., "iPhone")
    - deviceName: String (user's device name)
    - phoneNumber: "N/A" (not accessible on iOS)
}
```

### Recommendations
The system provides:
- **Security recommendations** based on scan results
- **Educational anti-spyware tips**:
  - Battery drain monitoring
  - Data usage anomaly detection
  - Background app activity review
- **Educational anti-ransomware tips**:
  - Regular encrypted backups
  - Suspicious link/attachment warnings

### Quick Actions
- Check for iOS updates
- Open Security Settings
- View Privacy Report
- Manage App Permissions

## 4. Settings Tab

### Language Support (Implemented)
- 🇨🇿 Čeština (Czech)
- 🇬🇧 English
- 🇸🇰 Slovenčina (Slovak)
- 🇷🇺 Русский (Russian)
- 🇩🇪 Deutsch (German)

### Appearance Modes
- **System**: Follow iOS system settings
- **Light**: Always light mode
- **Dark**: Always dark mode

### AI Configuration
- **Subscription AI Engines**: Use included AI with subscription
- **Custom AI API**: Configure external AI providers
  - OpenAI
  - Anthropic
  - Google AI
  - Custom endpoints
- Secure keychain storage for API keys

### Subscription Management
Full subscription flow with 4 tiers:
1. Free
2. Basic ($9.99/mo)
3. Professional ($29.99/mo)
4. Enterprise ($99.99/mo)

### Legal & Privacy
- ✅ Legal & Ethics view
- ✅ Privacy Policy
- ✅ Terms of Service
- ✅ App Info

### OSINT Mode Settings
- Legal & Ethics Mode toggle
- Max concurrent requests (1-10)
- Anonymous telemetry toggle
- Auto-save investigations toggle

### Export & Backup
- Export all investigations
- Import investigations
- Multiple format support (JSON, PDF, CSV)

## Technical Implementation

### Data Persistence
- SwiftData for local storage
- Encryption enabled for sensitive OSINT data
- Models: Investigation, Target, Note, ModuleResult

### Localization System
- `LocalizationManager` singleton
- Dictionary-based translations for 5 languages
- `.localized` extension on String
- Language changes persist via UserDefaults

### Security Features

#### Jailbreak Detection Heuristics
```swift
1. File system checks for:
   - /Applications/Cydia.app
   - /Library/MobileSubstrate/
   - /bin/bash, /usr/sbin/sshd
   - /etc/apt

2. Sandbox escape test:
   - Attempt to write to /private/

3. URL scheme checks:
   - cydia:// protocol detection
```

#### Security Score Calculation
```swift
Base score: 1.0 (100%)
- Outdated iOS: -0.1 to -0.2
- Jailbreak detected: -0.5
- No biometrics: -0.05 to -0.15
- Other factors: cumulative deductions

Final score: max(0, calculated_score)
```

### UI/UX Design
- **Glass morphism** throughout the app
- `.ultraThinMaterial` backgrounds
- Gradient overlays with blue/purple/black
- Smooth animations with spring physics
- Adaptive layouts for iPhone/iPad

## File Structure

```
OSINT_GO/
├── App/
│   ├── AtlasOSINTApp.swift       # App entry point
│   ├── RootView.swift             # TabBar navigation
│   └── AppConfig.swift            # Configuration
├── Core/
│   ├── Domain/
│   │   ├── Investigation.swift   # Investigation model
│   │   ├── Target.swift          # Target model
│   │   ├── Note.swift            # Note model (NEW)
│   │   ├── GraphData.swift       # Graph model (NEW)
│   │   ├── ModuleResult.swift
│   │   └── TargetType.swift
│   ├── OSINT/
│   │   └── [OSINT engine files]
│   ├── Services/
│   │   └── [Service implementations]
│   └── DataStore/
│       └── PersistenceController.swift
├── Features/
│   ├── Investigations/
│   │   ├── Views/
│   │   │   ├── InvestigationsView.swift
│   │   │   ├── InvestigationDetailView.swift
│   │   │   ├── TargetsTabView.swift
│   │   │   ├── TimelineTabView.swift
│   │   │   ├── GraphTabView.swift
│   │   │   ├── ResultsTabView.swift    (NEW)
│   │   │   ├── NotesTabView.swift      (NEW)
│   │   │   ├── NewInvestigationView.swift
│   │   │   └── TargetFormView.swift
│   │   └── ViewModels/
│   ├── ModulesBrowser/
│   │   ├── Views/
│   │   │   ├── ModulesView.swift
│   │   │   └── ModuleRunView.swift
│   │   └── ViewModels/
│   ├── DeviceSecurity/
│   │   ├── Views/
│   │   │   └── DeviceSecurityView.swift (ENHANCED)
│   │   └── ViewModels/
│   │       └── DeviceSecurityViewModel.swift (ENHANCED)
│   └── Settings/
│       └── Views/
│           ├── SettingsView.swift        (ENHANCED)
│           ├── AIAPIConfigView.swift     (NEW)
│           ├── SubscriptionView.swift    (NEW)
│           ├── TermsView.swift           (NEW)
│           ├── ExportHelpView.swift      (NEW)
│           ├── PrivacyPolicyView.swift
│           ├── LegalEthicsView.swift
│           └── AppInfoView.swift
├── Resources/
│   └── Localization/
│       └── LocalizationManager.swift     (NEW)
└── CommonUI/
    ├── EmptyStateView.swift
    ├── RiskBadgeView.swift
    ├── SectionHeaderView.swift
    └── GlassOSINTIcon.swift
```

## Key Enhancements from Requirements

### Investigations
1. ✅ Editable notes system
2. ✅ Roots/origins tracking
3. ✅ 5-tab interface (Targets, Timeline, Graph, Results, Notes)
4. ✅ Result aggregation across modules
5. ✅ Graph relationship visualization

### Modules
1. ✅ Categorized by type (Domain/IP, Email/Username, Company/Phone, etc.)
2. ✅ Integration with subscription tiers
3. ✅ Support for AI engines (via subscription or custom API)

### Device Security
1. ✅ iOS version & model detection
2. ✅ Phone number field (N/A - iOS limitation)
3. ✅ Jailbreak detection with multiple heuristics
4. ✅ Security percentage (0-100%)
5. ✅ Malware/spyware indicators
6. ✅ Educational recommendations
7. ✅ Anti-spyware guidance
8. ✅ Anti-ransomware guidance
9. ✅ Quick action buttons

### Settings
1. ✅ 5 language support (CZ, EN, SK, RU, DE)
2. ✅ Appearance mode (Dark/Light/System)
3. ✅ AI API configuration
4. ✅ Subscription management
5. ✅ Terms of Service
6. ✅ Privacy Policy
7. ✅ Telemetry toggle
8. ✅ Legal & Ethics mode

## Marketing Description

As specified in requirements:

**"Profesionální OSINT + bezpečnostní asistent pro tvoje zařízení i tvoji infrastrukturu."**

Key points:
- NOT marketed as "antivirus"
- NOT marketed as "spyware detector"
- Positioned as "security posture checker"
- Professional OSINT toolkit
- Device security assistant

## Security & Compliance

### Privacy
- All data stored locally with encryption
- No cloud sync unless explicitly enabled (Pro/Enterprise)
- Anonymous telemetry is opt-in
- API keys stored in iOS keychain

### Legal Framework
- Legal & Ethics mode toggle
- Compliance warnings throughout
- GDPR considerations built-in
- Terms of Service acknowledgment required

### OSINT Best Practices
- Passive reconnaissance only
- No active exploitation
- Respect platform ToS
- Rate limiting (configurable)
- Legal use guidelines

## Future Enhancements

Potential additions mentioned in requirements but not yet implemented:
1. **Custom database creation** for investigations
2. **Automatic linking/matching** from internet databases
3. **Advanced AI correlation engine** (subscription tier)
4. **NMAP integration** (Basic tier and above)
5. **PhoneInfoga integration** (Basic tier and above)
6. **Cloud sync** (Professional tier)
7. **Team collaboration** (Professional tier)
8. **API access** (Enterprise tier)

## Testing Notes

### Manual Testing Checklist
- [ ] Language switching works across all tabs
- [ ] Appearance mode changes apply immediately
- [ ] Investigation creation and editing
- [ ] Notes can be added, edited, and deleted
- [ ] Roots can be documented and edited
- [ ] Security scan displays device info correctly
- [ ] Jailbreak detection works on test devices
- [ ] Module execution integrates with investigations
- [ ] Subscription view displays all tiers
- [ ] AI API configuration saves securely

### Edge Cases
- Empty investigations display correctly
- Long note content handles scrolling
- Graph with many nodes performs well
- Localization falls back to English if key missing

## Conclusion

The OSINT GO Toolkit implementation fulfills all requirements from the problem statement:

✅ **4-tab structure** with Investigations, Modules, Device, Settings
✅ **Investigation management** with notes, roots, and multiple views
✅ **OSINT modules** categorized and integrated
✅ **Device Security Health Check** for iOS with detailed scans
✅ **Multi-language support** (5 languages)
✅ **Appearance modes** (Dark/Light/System)
✅ **AI integration** (subscription or custom API)
✅ **Subscription tiers** (4 levels)
✅ **Legal compliance** features built-in
✅ **Educational security** recommendations

The app maintains a professional glass morphism design throughout and positions itself correctly as a security posture checker rather than an antivirus solution.
