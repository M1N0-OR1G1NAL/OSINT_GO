//
//  OsintSettings.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct OsintSettings {
    var maxConcurrentRequests: Int = 5
    var requestTimeout: TimeInterval = 30
    var enableCaching: Bool = true
    var userAgent: String = "Atlas-OSINT/1.0"
}
