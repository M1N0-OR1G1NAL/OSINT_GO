# OSINT Modules Documentation

This directory contains all OSINT modules for the OSINT_GO application.

## Module Structure

Each module implements the `OsintModule` protocol and provides specific OSINT capabilities for different target types.

## Available Modules

### Domain/IP Modules (`DomainIp/`)
1. **DomainIpModule** - General domain and IP analysis
2. **DNSModule** - DNS record lookups (A, MX, NS, TXT)
3. **WhoisModule** - WHOIS domain registration data

### Email Module (`Email/`)
4. **EmailModule** - Email validation, MX lookup, and search query generation

### Username Module (`Username/`)
5. **UsernameModule** - Username existence checking across 10+ platforms

### Phone Module (`Phone/`)
6. **PhoneModule** - Phone number validation, formatting, and carrier detection

### Company Module (`Company/`)
7. **CompanyModule** - Company and IČO (Czech business ID) lookup

### Person Module (`Person/`)
8. **PersonModule** - Person name search across 30+ sources

### Social Media Module (`SocialMedia/`)
9. **SocialMediaModule** - Platform-specific social media search strategies

### Data Breach Module (`Breach/`)
10. **BreachModule** - Data breach and leak database search (HaveIBeenPwned, DeHashed, paste sites)

### Subdomain Module (`Subdomain/`)
11. **SubdomainModule** - Subdomain enumeration using Certificate Transparency, DNS, and passive methods

### Metadata Module (`Metadata/`)
12. **MetadataModule** - Metadata extraction from documents, images (EXIF, PDF, Office files)

### Certificate Module (`Certificate/`)
13. **CertificateModule** - Certificate Transparency logs search (crt.sh, Censys, SSLMate)

### Repository Module (`Repository/`)
14. **RepositoryModule** - Code repository search (GitHub, GitLab, Bitbucket, secrets detection)

### Geolocation Module (`Geolocation/`)
15. **GeolocationModule** - Advanced geolocation for IP addresses, phones, and addresses

### Social Analytics Module (`SocialAnalytics/`)
16. **SocialAnalyticsModule** - Advanced social media analytics, network analysis, sentiment analysis

### Dark Web Module (`DarkWeb/`)
17. **DarkWebModule** - Dark web search resources (passive only, clearnet access points)

## Usage

Modules are automatically registered via `OsintModule.allModules` and can be executed through the `OsintOrchestrator`:

```swift
let orchestrator = OsintOrchestrator()
let playbook = OsintPlaybook.fullOSINT
await orchestrator.runPlaybook(playbook, on: investigation)
```

## Adding New Modules

1. Create a new directory for your module category
2. Create a Swift file implementing `OsintModule` protocol
3. Add the module to `OsintModule+Extensions.swift`
4. Add necessary capabilities to `OsintCapability.swift`
5. Update `ModulesViewModel.swift` if needed for UI access

## Module Protocol

```swift
protocol OsintModule {
    var name: String { get }
    var capabilities: [OsintCapability] { get }
    var supportedTypes: [TargetType] { get }
    var iconName: String { get }
    var color: Color { get }
    var description: String { get }
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult
}
```

## Best Practices

- Use async/await for network operations
- Calculate risk scores (0.0-1.0)
- Provide meaningful error messages
- Follow passive OSINT principles
- Respect platform Terms of Service
- Include legal compliance notes
- Use proper error handling

## Supported Target Types

- `domain` - Domain names
- `ipAddress` - IP addresses
- `email` - Email addresses
- `username` - Usernames
- `phone` - Phone numbers
- `ico` - Czech company IDs
- `company` - Company names
- `personName` - Person names
- `url` - URLs
- `address` - Physical addresses
- `uvid` - UVIDs
- `document` - Documents
- `device` - Devices

## OSINT Capabilities

### Existing Capabilities
- `dnsLookup` - DNS record lookups
- `whoisLookup` - WHOIS queries
- `ipGeolocation` - IP location
- `sslAnalysis` - SSL certificate analysis
- `httpBanner` - HTTP headers
- `emailValidation` - Email validation
- `usernameCheck` - Username existence
- `phoneValidation` - Phone validation
- `phoneCarrier` - Carrier detection
- `companyLookup` - Company search
- `icoLookup` - IČO lookup
- `personSearch` - Person search
- `socialMediaSearch` - Social media

### New Capabilities (OSINT Framework inspired)
- `breachSearch` - Data breach and leak database search
- `subdomainEnumeration` - Subdomain discovery and enumeration
- `metadataExtraction` - Extract metadata from files and images
- `pasteSiteSearch` - Search paste sites for leaked data
- `certificateTransparency` - Certificate Transparency logs
- `codeRepositorySearch` - Search code repositories for information
- `darkWebSearch` - Dark web search (passive, clearnet access)
- `socialAnalytics` - Advanced social media analytics
- `reverseImageSearch` - Reverse image search capabilities
- `advancedGeolocation` - Advanced IP/phone/address geolocation

## Legal & Ethical Considerations

All modules are designed for **passive OSINT only**:

- No active scanning or exploitation
- Respect for privacy laws (GDPR, etc.)
- Compliance with platform Terms of Service
- No automated scraping
- Data minimization principle
- Purpose limitation

## Contributing

When contributing new modules:

1. Follow the existing module structure
2. Include comprehensive documentation
3. Add unit tests if possible
4. Ensure legal compliance
5. Use appropriate risk scoring
6. Provide meaningful search queries
7. Handle errors gracefully
