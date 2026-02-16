// Path: AtlasOSINT/Core/Services/SecurityCheckService.swift

import Foundation

final class SecurityCheckService {
    private let localAuth: LocalAuthService

    init(localAuth: LocalAuthService = LocalAuthService()) {
        self.localAuth = localAuth
    }

    func buildDeviceSecurityReport() -> DeviceSecurityReport {
        let info = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(info.majorVersion).\(info.minorVersion).\(info.patchVersion)"

        let isOutdated = info.majorVersion < 17  // příklad logiky

        let biometricsAvailable = localAuth.canEvaluatePolicy()
        let passcodeLikelyEnabled = biometricsAvailable // hrubý odhad

        let jailbreakSuspected = JailbreakHeuristics.isJailbreakSuspected()

        var recommendations: [String] = []

        if isOutdated {
            recommendations.append("Update iOS to the latest version to patch known vulnerabilities.")
        }
        if !passcodeLikelyEnabled {
            recommendations.append("Set a strong device passcode and enable Face ID / Touch ID.")
        }
        if jailbreakSuspected {
            recommendations.append("Device appears to be jailbroken. This significantly weakens iOS security.")
        }
        if recommendations.isEmpty {
            recommendations.append("Your device configuration looks reasonable. Keep iOS updated and be cautious of phishing and untrusted profiles.")
        }

        return DeviceSecurityReport(
            iosVersion: versionString,
            isVersionOutdated: isOutdated,
            biometricsAvailable: biometricsAvailable,
            passcodeLikelyEnabled: passcodeLikelyEnabled,
            jailbreakSuspected: jailbreakSuspected,
            recommendations: recommendations
        )
    }
}