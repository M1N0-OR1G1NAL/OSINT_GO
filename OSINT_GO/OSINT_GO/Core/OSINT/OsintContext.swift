//
//  OsintContext.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct OsintContext {
    let httpClient: HTTPClient
    let cache: CacheManager
    let settings: OsintSettings
    
    init(httpClient: HTTPClient = HTTPClient.shared,
         cache: CacheManager = CacheManager.shared,
         settings: OsintSettings = OsintSettings()) {
        self.httpClient = httpClient
        self.cache = cache
        self.settings = settings
    }
}
