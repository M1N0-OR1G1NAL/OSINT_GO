//
//  SettingsView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("legalModeEnabled") private var legalModeEnabled = true
    @AppStorage("telemetryEnabled") private var telemetryEnabled = false
    @AppStorage("maxConcurrentRequests") private var maxConcurrentRequests = 5
    @AppStorage("autoSaveInvestigations") private var autoSaveInvestigations = true
    
    @State private var showingLegalEthics = false
    @State private var showingExportHelp = false
    
    var body: some View {
        NavigationView {
            List {
                Section("OSINT Mode") {
                    Toggle("Legal & Ethics Mode", isOn: $legalModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    LabeledContent("Max concurrent requests") {
                        Stepper("\(maxConcurrentRequests)", value: $maxConcurrentRequests, in: 1...10)
                    }
                }
                
                Section("Privacy & Data") {
                    Toggle("Anonymous Telemetry", isOn: $telemetryEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                    Toggle("Auto-save Investigations", isOn: $autoSaveInvestigations)
                }
                
                Section("Export & Backup") {
                    Button("Export All Investigations") {
                        exportAllInvestigations()
                    }
                    .foregroundStyle(.blue)
                    
                    Button("Import Investigations") {
                        // TODO: Import logic
                    }
                    .foregroundStyle(.blue)
                }
                
                Section("Legal & Info") {
                    Button("Legal & Ethics") {
                        showingLegalEthics = true
                    }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("App Info") {
                        AppInfoView()
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingLegalEthics) {
                LegalEthicsView()
            }
            .sheet(isPresented: $showingExportHelp) {
                ExportHelpView()
            }
        }
    }
    
    private func exportAllInvestigations() {
        // Export logic - viz níže
        showingExportHelp = true
    }
}
