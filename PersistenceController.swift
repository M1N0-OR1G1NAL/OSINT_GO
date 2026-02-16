//
//  PersistenceController.swift
//  OSINT
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//



import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Investigation.self, Target.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}