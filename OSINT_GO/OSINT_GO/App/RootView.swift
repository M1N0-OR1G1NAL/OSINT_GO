//
//  RootView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct RootView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            // GLASS BACKGROUND – gradient přes celou app
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.5),
                    Color.purple.opacity(0.7),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                InvestigationsView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Investigations")
                    }

                ModulesView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("Modules")
                    }

                DeviceSecurityView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "shield.lefthalf.filled")
                        Text("Device")
                    }

                SettingsView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "gearshape.2.fill")
                        Text("Settings")
                    }
            }
            .tint(.white)
            .onChange(of: selectedTab) { _, _ in
                // jemná animace při přepnutí tabu
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {}
            }
        }
    }
}
