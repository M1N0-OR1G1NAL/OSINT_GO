//
//  AppConfig.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct AppConfig {
    static let appName = "Atlas OSINT"
    static let appVersion = "1.0.0"
    static let maxConcurrentRequests = 5
    static let requestTimeout: TimeInterval = 30
    
    enum API {
        static let whoisBaseURL = "https://rdap.arin.net/registry"
        static let ipInfoURL = "https://ipinfo.io"
        static let crtshURL = "https://crt.sh"
    }
}
