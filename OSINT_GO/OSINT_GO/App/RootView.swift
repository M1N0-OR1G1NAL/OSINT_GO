//
//  RootView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct RootView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("appAppearance") private var appAppearance = AppAppearance.system.rawValue

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
                        Text("investigations".localized)
                    }

                ModulesView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("modules".localized)
                    }

                DeviceSecurityView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "shield.lefthalf.filled")
                        Text("device".localized)
                    }

                SettingsView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "gearshape.2.fill")
                        Text("settings".localized)
                    }
            }
            .tint(.white)
            .onChange(of: selectedTab) { _, _ in
                // jemná animace při přepnutí tabu
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {}
            }
        }
        .preferredColorScheme(getColorScheme())
    }
    
    private func getColorScheme() -> ColorScheme? {
        guard let appearance = AppAppearance(rawValue: appAppearance) else {
            return nil
        }
        
        switch appearance {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
