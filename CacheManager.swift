//
//  CacheManager.swift
//  OSINT
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import Foundation

final class CacheManager {
    static let shared = CacheManager()

    private let cache = NSCache<NSString, AnyObject>()

    private init() {}

    func object(forKey key: String) -> Any? {
        cache.object(forKey: key as NSString)
    }

    func set(_ object: Any, forKey key: String) {
        cache.setObject(object as AnyObject, forKey: key as NSString)
    }

    func removeObject(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
