//
//  CacheManager.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

class CacheManager {
    static let shared = CacheManager()
    private var cache: [String: Any] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    func get(_ key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }
    
    func set(_ key: String, value: Any) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = value
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}
