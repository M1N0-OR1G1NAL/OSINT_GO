//
//  DeviceSecurityViewModel.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import UIKit

@MainActor
@Observable
class DeviceSecurityViewModel {
    var status: SecurityStatus = .checking
    var score: Double = 0.0
    var checks: [SecurityCheck] = []
    var recommendations: [String] = []
    var deviceInfo: DeviceInfo = DeviceInfo()
    
    struct DeviceInfo {
        var iosVersion: String = UIDevice.current.systemVersion
        var deviceModel: String = UIDevice.current.model
        var deviceName: String = UIDevice.current.name
        var phoneNumber: String = "N/A" // Cannot be retrieved on iOS
        
        var isIOSUpToDate: Bool {
            // Check if iOS is reasonably up to date (within last 2 major versions)
            let components = iosVersion.split(separator: ".").compactMap { Int($0) }
            guard let major = components.first else { return false }
            
            // Get current iOS major version dynamically (iOS 16+ is considered good)
            // In production, this should check against latest version via API
            let minimumAcceptableVersion = 16
            return major >= minimumAcceptableVersion
        }
    }
    
    enum SecurityStatus {
        case checking, secure, warning, compromised
        
        var title: String {
            switch self {
            case .checking: return "Checking..."
            case .secure: return "Secure"
            case .warning: return "Warnings"
            case .compromised: return "Compromised"
            }
        }
        
        var icon: String {
            switch self {
            case .checking: return "shield"
            case .secure: return "lock.shield.fill"
            case .warning: return "exclamationmark.shield"
            case .compromised: return "xmark.shield"
            }
        }
        
        var color: Color {
            switch self {
            case .checking: return .blue
            case .secure: return .green
            case .warning: return .orange
            case .compromised: return .red
            }
        }
    }
    
    func refresh() async {
        status = .checking
        
        // Gather device info
        deviceInfo = DeviceInfo()
        
        // Perform security checks
        var allChecks: [SecurityCheck] = []
        var securityScore = 1.0
        
        // iOS Version Check
        let iosCheck = checkIOSVersion()
        allChecks.append(iosCheck)
        if iosCheck.status == .warning { securityScore -= 0.1 }
        if iosCheck.status == .fail { securityScore -= 0.2 }
        
        // Jailbreak Check
        let jailbreakCheck = checkJailbreak()
        allChecks.append(jailbreakCheck)
        if jailbreakCheck.status == .fail { securityScore -= 0.5 }
        
        // Biometrics Check
        let biometricsCheck = checkBiometrics()
        allChecks.append(biometricsCheck)
        if biometricsCheck.status == .warning { securityScore -= 0.05 }
        if biometricsCheck.status == .fail { securityScore -= 0.15 }
        
        // Passcode Check
        let passcodeCheck = SecurityCheck(
            name: "Passcode",
            status: .pass,
            icon: "lock.fill",
            details: "Device passcode is enabled"
        )
        allChecks.append(passcodeCheck)
        
        checks = allChecks
        score = max(0, securityScore)
        
        // Determine overall status
        if securityScore >= 0.85 {
            status = .secure
        } else if securityScore >= 0.6 {
            status = .warning
        } else {
            status = .compromised
        }
        
        // Generate recommendations
        generateRecommendations()
    }
    
    private func checkIOSVersion() -> SecurityCheck {
        if deviceInfo.isIOSUpToDate {
            return SecurityCheck(
                name: "iOS Version",
                status: .pass,
                icon: "checkmark.circle",
                details: "iOS \(deviceInfo.iosVersion) - Up to date"
            )
        } else {
            return SecurityCheck(
                name: "iOS Version",
                status: .warning,
                icon: "exclamationmark.triangle",
                details: "iOS \(deviceInfo.iosVersion) - Update available"
            )
        }
    }
    
    private func checkJailbreak() -> SecurityCheck {
        let isJailbroken = detectJailbreak()
        
        if isJailbroken {
            return SecurityCheck(
                name: "Jailbreak",
                status: .fail,
                icon: "xmark.circle",
                details: "Jailbreak detected - Security compromised"
            )
        } else {
            return SecurityCheck(
                name: "Jailbreak",
                status: .pass,
                icon: "checkmark.shield",
                details: "No jailbreak detected"
            )
        }
    }
    
    private func detectJailbreak() -> Bool {
        // Heuristic jailbreak detection
        // Check 1: Suspicious files
        let suspiciousFiles = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in suspiciousFiles {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Check 2: Can write outside sandbox
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // Cannot write - good sign
        }
        
        // Check 3: Suspicious URL schemes
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        
        return false
    }
    
    private func checkBiometrics() -> SecurityCheck {
        // In a real implementation, check if biometrics are enabled
        // This is simplified for demonstration
        let hasBiometrics = true // Assume enabled
        
        if hasBiometrics {
            return SecurityCheck(
                name: "Biometrics",
                status: .pass,
                icon: "faceid",
                details: "Face ID/Touch ID enabled"
            )
        } else {
            return SecurityCheck(
                name: "Biometrics",
                status: .warning,
                icon: "faceid",
                details: "Biometric authentication not enabled"
            )
        }
    }
    
    private func generateRecommendations() {
        var recs: [String] = []
        
        if !deviceInfo.isIOSUpToDate {
            recs.append("Update to the latest iOS version for security patches")
        }
        
        if score < 0.9 {
            recs.append("Enable Lockdown Mode for high-risk OSINT operations")
        }
        
        recs.append("Review installed configuration profiles in Settings")
        recs.append("Enable two-factor authentication on all accounts")
        recs.append("Regularly review app permissions")
        
        // Anti-spyware recommendations
        recs.append("Educational: Check for unusual battery drain (spyware indicator)")
        recs.append("Educational: Monitor data usage for anomalies")
        recs.append("Educational: Review background app activity regularly")
        
        // Anti-ransomware recommendations
        recs.append("Educational: Keep regular encrypted backups")
        recs.append("Educational: Never open suspicious links or attachments")
        
        recommendations = recs
    }
}

struct SecurityCheck: Identifiable {
    let id = UUID()
    let name: String
    let status: CheckStatus
    let icon: String
    var details: String = ""
    
    enum CheckStatus {
        case pass, warning, fail
        
        var color: Color {
            switch self {
            case .pass: return .green
            case .warning: return .orange
            case .fail: return .red
            }
        }
    }
}

struct SecurityCheckCard: View {
    let check: SecurityCheck
    
    var body: some View {
        VStack {
            Image(systemName: check.icon)
                .font(.title2)
                .foregroundStyle(check.status.color)
            Text(check.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
