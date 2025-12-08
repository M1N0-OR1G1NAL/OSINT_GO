//
//  AtlasOSINTApp.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


// OSINT_GO/App/AtlasOSINTApp.swift

import SwiftUI
import SwiftData

@main
struct AtlasOSINTApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(persistenceController.container)
        }
    }
}
