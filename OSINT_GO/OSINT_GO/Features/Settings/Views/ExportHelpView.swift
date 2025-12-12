//
//  ExportHelpView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct ExportHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Export Complete", systemImage: "checkmark.circle.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                        
                        Text("Your investigations have been exported successfully.")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Formats")
                            .font(.headline)
                        
                        ExportFormatRow(
                            format: "JSON",
                            description: "Machine-readable format for data analysis",
                            icon: "doc.text"
                        )
                        
                        ExportFormatRow(
                            format: "PDF",
                            description: "Human-readable report format",
                            icon: "doc.richtext"
                        )
                        
                        ExportFormatRow(
                            format: "CSV",
                            description: "Spreadsheet-compatible format",
                            icon: "tablecells"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's Included")
                            .font(.headline)
                        
                        FeatureRow(icon: "target", text: "All investigation targets")
                        FeatureRow(icon: "chart.bar", text: "Module results and findings")
                        FeatureRow(icon: "clock", text: "Timeline events")
                        FeatureRow(icon: "link", text: "Relationship graphs")
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Security Note")
                            .font(.headline)
                        
                        Label {
                            Text("Exported data contains sensitive OSINT information. Store securely and handle according to applicable privacy laws.")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .navigationTitle("Export Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportFormatRow: View {
    let format: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(format)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ExportHelpView()
}
