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
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @AppStorage("appAppearance") private var appAppearance = AppAppearance.system.rawValue
    @AppStorage("aiApiKey") private var aiApiKey = ""
    @AppStorage("useSubscriptionAI") private var useSubscriptionAI = false
    
    @State private var showingLegalEthics = false
    @State private var showingExportHelp = false
    @State private var showingAPIConfig = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Language & Appearance") {
                    Picker("Language", selection: $appLanguage) {
                        ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }
                    .onChange(of: appLanguage) { _, newValue in
                        // Sync with LocalizationManager
                        if let language = AppLanguage(rawValue: newValue) {
                            LocalizationManager.shared.currentLanguage = language
                        }
                    }
                    
                    Picker("Appearance", selection: $appAppearance) {
                        ForEach(AppAppearance.allCases, id: \.rawValue) { appearance in
                            Text(appearance.displayName).tag(appearance.rawValue)
                        }
                    }
                }
                
                Section("AI Configuration") {
                    Toggle("Use Subscription AI Engines", isOn: $useSubscriptionAI)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    
                    if !useSubscriptionAI {
                        Button("Configure AI API") {
                            showingAPIConfig = true
                        }
                        .foregroundStyle(.blue)
                    }
                    
                    if !aiApiKey.isEmpty {
                        Label("API Key Configured", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                
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
                
                Section("Subscription") {
                    NavigationLink {
                        SubscriptionView()
                    } label: {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("Manage Subscription")
                        }
                    }
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
                    
                    NavigationLink("Terms of Service") {
                        TermsView()
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
            .sheet(isPresented: $showingAPIConfig) {
                AIAPIConfigView(apiKey: $aiApiKey)
            }
        }
    }
    
    private func exportAllInvestigations() {
        // Export logic - viz níže
        showingExportHelp = true
    }
}
