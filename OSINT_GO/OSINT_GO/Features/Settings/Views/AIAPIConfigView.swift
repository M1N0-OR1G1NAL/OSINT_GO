//
//  AIAPIConfigView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct AIAPIConfigView: View {
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProvider: AIProvider = .openai
    @State private var tempApiKey = ""
    
    enum AIProvider: String, CaseIterable {
        case openai = "OpenAI"
        case anthropic = "Anthropic"
        case google = "Google AI"
        case custom = "Custom"
        
        var instructions: String {
            switch self {
            case .openai:
                return "Get your API key from platform.openai.com/api-keys"
            case .anthropic:
                return "Get your API key from console.anthropic.com"
            case .google:
                return "Get your API key from makersuite.google.com/app/apikey"
            case .custom:
                return "Enter your custom API endpoint and key"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("AI Provider") {
                    Picker("Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    
                    Text(selectedProvider.instructions)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("API Configuration") {
                    SecureField("API Key", text: $tempApiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                    
                    if !tempApiKey.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Key entered")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Features") {
                    FeatureRow(
                        icon: "brain",
                        title: "AI-Powered Analysis",
                        description: "Intelligent pattern recognition and correlation"
                    )
                    FeatureRow(
                        icon: "link",
                        title: "Connection Discovery",
                        description: "Automatically find relationships between entities"
                    )
                    FeatureRow(
                        icon: "doc.text.magnifyingglass",
                        title: "Information Gathering",
                        description: "Enhanced data collection from multiple sources"
                    )
                }
                
                Section {
                    Label {
                        Text("Your API key is stored securely in the keychain and never shared with third parties.")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("AI API Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        apiKey = tempApiKey
                        dismiss()
                    }
                    .disabled(tempApiKey.isEmpty)
                }
            }
            .onAppear {
                tempApiKey = apiKey
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AIAPIConfigView(apiKey: .constant(""))
}
