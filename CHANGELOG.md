# Changelog

All notable changes to the OSINT_GO application will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-12

### Added
- **Import/Export Functionality**: Complete implementation of investigation import/export system
  - New `ImportService` for importing investigations from JSON files
  - File picker integration in Settings for selecting import files
  - Comprehensive error handling for import operations
  - Support for both full and summary investigation exports
  - Version compatibility checking for imports (1.0.x and 1.1.x)
  
- **ExportHelpView**: New help screen explaining export functionality
  - Export format documentation
  - File location information
  - Usage guidelines
  - Privacy and security warnings
  
- **Dynamic App Info**: AppInfoView now displays real-time data
  - Shows actual module count from `OsintModule.allModules`
  - Shows actual investigation count from SwiftData
  - Displays current app version from `AppConfig`

### Changed
- **Version Update**: App version updated from 1.0.0 to 1.1.0
- **SettingsView**: Enhanced with full import/export functionality
  - Added file importer with JSON file type filter
  - Added alert system for import/export success/failure notifications
  - Improved export functionality with proper error handling
  - Removed TODO comment - import functionality now implemented

### Fixed
- Import service now properly initializes Target with TargetType enum
- Import service correctly includes targetId in ModuleResult initialization
- Export/import operations now properly handle SwiftData ModelContext

### Technical Details
- Added SwiftData and UniformTypeIdentifiers imports to SettingsView
- Created ImportError enum with localized error descriptions
- Implemented security-scoped resource access for file operations
- Added JSON validation and structure checking for imports

## [1.0.0] - 2025-12-08

### Added
- Initial release of OSINT_GO application
- Core OSINT modules:
  - Domain/IP Module
  - DNS Module
  - WHOIS Module
  - Email Module
  - Username Module
  - Phone Module
  - Company Module
  - Person Module
  - Social Media Module
- SwiftUI user interface
- SwiftData persistence
- Investigation management
- Target tracking
- Risk scoring system
- Legal and ethics mode
- Privacy policy and app info screens
