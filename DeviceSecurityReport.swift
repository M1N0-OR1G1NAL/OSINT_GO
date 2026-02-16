// Path: AtlasOSINT/Core/Domain/DeviceSecurityReport.swift

import Foundation

struct DeviceSecurityReport: Codable, Hashable {
    let iosVersion: String
    let isVersionOutdated: Bool
    let biometricsAvailable: Bool
    let passcodeLikelyEnabled: Bool
    let jailbreakSuspected: Bool
    let recommendations: [String]
    let generatedAt: Date

    init(
        iosVersion: String,
        isVersionOutdated: Bool,
        biometricsAvailable: Bool,
        passcodeLikelyEnabled: Bool,
        jailbreakSuspected: Bool,
        recommendations: [String],
        generatedAt: Date = Date()
    ) {
        self.iosVersion = iosVersion
        self.isVersionOutdated = isVersionOutdated
        self.biometricsAvailable = biometricsAvailable
        self.passcodeLikelyEnabled = passcodeLikelyEnabled
        self.jailbreakSuspected = jailbreakSuspected
        self.recommendations = recommendations
        self.generatedAt = generatedAt
    }
}