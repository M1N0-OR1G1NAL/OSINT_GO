//
//  RootView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI

enum Section: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case apps = "Aplikace"
    case secure = "Secure"
    case devices = "Zařízení"
    case vpn = "VPN"
    case settings = "Nastavení"
    case help = "Nápověda"
    
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .dashboard: return "speedometer"
        case .apps: return "rectangle.grid.2x2"
        case .secure: return "shield.lefthalf.filled"
        case .devices: return "desktopcomputer"
        case .vpn: return "lock.shield"
        case .settings: return "gear"
        case .help: return "questionmark.circle"
        }
    }
}

struct RootView: View {
    @State private var selection: Section = .dashboard
    
    var body: some View {
        #if os(macOS) || os(iPadOS)
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            content
        }
        .background(Color.black)
        #else
        TabView(selection: $selection) {
            contentFor(.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: Section.dashboard.icon)
                }
                .tag(Section.dashboard)
            
            contentFor(.secure)
                .tabItem {
                    Label("Secure", systemImage: Section.secure.icon)
                }
                .tag(Section.secure)
            
            contentFor(.vpn)
                .tabItem {
                    Label("VPN", systemImage: Section.vpn.icon)
                }
                .tag(Section.vpn)
            
            contentFor(.devices)
                .tabItem {
                    Label("Zařízení", systemImage: Section.devices.icon)
                }
                .tag(Section.devices)
        }
        #endif
    }
    
    private var content: some View {
        contentFor(selection)
    }
    
    @ViewBuilder
    private func contentFor(_ section: Section) -> some View {
        switch section {
        case .dashboard:
            DashboardView()
        case .apps:
            AppsView()
        case .secure:
            SecureView()
        case .devices:
            DevicesView()
        case .vpn:
            VPNView()
        case .settings:
            SettingsView()
        case .help:
            HelpView()
        }
    }
}

struct Sidebar: View {
    @Binding var selection: Section
    
    var body: some View {
        List(Section.allCases, selection: $selection) { section in
            Label(section.rawValue, systemImage: section.icon)
        }
        .listStyle(.sidebar)
        .background(Color.black)
    }
}
