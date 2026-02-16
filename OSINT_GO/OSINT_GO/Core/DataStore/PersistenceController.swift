//
//  PersistenceController.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


// OSINT_GO/Core/DataStore/PersistenceController.swift

import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        do {
            // sem patří všechny tvoje @Model třídy
            container = try ModelContainer(
                for: Investigation.self, Target.self, Note.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
