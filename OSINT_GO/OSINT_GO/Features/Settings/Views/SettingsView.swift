//
//  SettingsView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("legalModeEnabled") private var legalModeEnabled = true
    @AppStorage("telemetryEnabled") private var telemetryEnabled = false
    @AppStorage("maxConcurrentRequests") private var maxConcurrentRequests = 5
    @AppStorage("autoSaveInvestigations") private var autoSaveInvestigations = true
    
    @State private var showingLegalEthics = false
    @State private var showingExportHelp = false
    @State private var showingImportPicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
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
                        showingImportPicker = true
                    }
                    .foregroundStyle(.blue)
                    
                    Button("Export/Import Help") {
                        showingExportHelp = true
                    }
                    .foregroundStyle(.secondary)
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
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func exportAllInvestigations() {
        do {
            let exportURL = try ExportService.shared.exportAllInvestigations(context: modelContext)
            alertTitle = "Export Successful"
            alertMessage = "Investigations exported to: \(exportURL.lastPathComponent)"
            showingAlert = true
        } catch {
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let count = try ImportService.shared.importInvestigations(from: url, context: modelContext)
                alertTitle = "Import Successful"
                alertMessage = "Successfully imported \(count) investigation(s)."
                showingAlert = true
            } catch {
                alertTitle = "Import Failed"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
        case .failure(let error):
            alertTitle = "Import Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}
