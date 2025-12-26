//
//  Personal_InteligenceApp.swift
//  Personal_Inteligence
//
//  Created by M1N0-H1DDEN on 25.11.2025.
//


import SwiftUI

@main
struct Personal_InteligenceApp: App {
    @StateObject private var engine = PersonalEngine()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(engine)
                .environmentObject(locationManager)
        }
    }
}
