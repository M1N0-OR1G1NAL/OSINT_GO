# OSINT_GO

Multiplatformní SwiftUI OSINT nástroj pro iOS/iPadOS/AR brýle s robustním jádrem. Podporuje paralelní sběr, korelace a vizualizace dat, šifrovanou persistenci, modulární OSINT engine a důraz na bezpečnost, právní rámec a profesionální UX.

## Version 1.2.0

### New Features
- ✅ Complete Import/Export functionality for investigations
- ✅ Dynamic app information display
- ✅ Enhanced error handling and user notifications
- ✅ Export help documentation
- ✅ **8 New OSINT Modules** inspired by OSINT Framework (osintframework.com)

### OSINT Modules (17 Total)

#### Core Modules
- **Domain/IP**: DNS records, WHOIS, domain analysis
- **Email**: Validation, MX lookup, search queries
- **Username**: Multi-platform username checking (10+ platforms)
- **Phone**: Number validation, formatting, carrier detection
- **Company**: Czech IČO lookup, ARES integration
- **Person**: Comprehensive person search (30+ sources)
- **Social Media**: Platform-specific search strategies

#### New Advanced Modules (v1.2.0)
- **Data Breach Search**: HaveIBeenPwned, DeHashed, paste site search
- **Subdomain Enumeration**: Certificate Transparency, DNS-based discovery
- **Metadata Extraction**: EXIF, PDF, Office document metadata
- **Certificate Transparency**: SSL/TLS certificate logs (crt.sh, Censys)
- **Code Repository Search**: GitHub, GitLab, Bitbucket, secrets detection
- **Advanced Geolocation**: IP, phone, address geolocation
- **Social Analytics**: Advanced social media analysis, network mapping
- **Dark Web Search**: Passive dark web search (clearnet access points only)

### Documentation
- See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for detailed module documentation
- See [CHANGELOG.md](CHANGELOG.md) for version history
- See [COMPLETION_REPORT.md](COMPLETION_REPORT.md) for implementation details

### Requirements
- iOS 17.0+ / iPadOS 17.0+ / macOS 14.0+
- Swift 5.9+
- SwiftUI framework
- SwiftData framework

### Legal & Ethics
All modules are designed for **passive OSINT only**. Users must comply with:
- Local privacy laws (GDPR, etc.)
- Platform Terms of Service
- Ethical OSINT practices

No active scanning, exploitation, or ToS violations are performed by this application.

