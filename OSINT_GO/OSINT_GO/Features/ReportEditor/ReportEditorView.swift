//
//  ReportEditorView.swift
//  OSINT_GO
//
//  Interactive report editor with GUI
//

import SwiftUI

struct ReportEditorView: View {
    @StateObject private var viewModel: ReportEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(report: InvestigativeReport) {
        _viewModel = StateObject(wrappedValue: ReportEditorViewModel(report: report))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Header Section
                Section("Základní informace") {
                    TextField("Název reportu", text: $viewModel.report.title)
                    
                    TextField("Autor", text: $viewModel.report.author)
                    
                    Picker("Status", selection: $viewModel.report.status) {
                        ForEach([
                            InvestigativeReport.ReportStatus.draft,
                            .review,
                            .final,
                            .archived
                        ], id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    HStack {
                        Text("Vytvořeno")
                        Spacer()
                        Text(viewModel.report.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Executive Summary
                Section("Shrnutí pro vedení") {
                    TextEditor(text: $viewModel.report.executiveSummary)
                        .frame(minHeight: 100)
                }
                
                // Objectives
                Section("Cíle vyšetřování") {
                    TextEditor(text: $viewModel.report.objectives)
                        .frame(minHeight: 80)
                }
                
                // Methodology
                Section("Metodologie") {
                    TextEditor(text: $viewModel.report.methodology)
                        .frame(minHeight: 80)
                }
                
                // Findings
                Section {
                    ForEach($viewModel.report.findings) { $finding in
                        NavigationLink {
                            FindingEditorView(finding: $finding)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(finding.title)
                                        .font(.headline)
                                    Spacer()
                                    severityBadge(finding.severity)
                                }
                                Text(finding.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.report.findings.remove(atOffsets: indexSet)
                    }
                    
                    Button {
                        viewModel.addFinding()
                    } label: {
                        Label("Přidat nález", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Nálezy (\(viewModel.report.findings.count))")
                }
                
                // Correlations
                Section {
                    ForEach($viewModel.report.correlations) { $correlation in
                        NavigationLink {
                            CorrelationEditorView(correlation: $correlation)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("\(correlation.target1Name) ↔ \(correlation.target2Name)")
                                        .font(.headline)
                                    Spacer()
                                    confidenceBadge(correlation.confidence)
                                }
                                Text(correlation.matchType)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.report.correlations.remove(atOffsets: indexSet)
                    }
                } header: {
                    Text("Korelace (\(viewModel.report.correlations.count))")
                }
                
                // Risk Assessment
                Section("Hodnocení rizika") {
                    Picker("Celkové riziko", selection: $viewModel.report.riskAssessment.overallRisk) {
                        ForEach(RiskAssessment.RiskLevel.allCases, id: \.self) { level in
                            Label(level.rawValue, systemImage: "exclamationmark.triangle")
                                .tag(level)
                        }
                    }
                    
                    TextEditor(text: $viewModel.report.riskAssessment.notes)
                        .frame(minHeight: 60)
                }
                
                // Recommendations
                Section {
                    ForEach(viewModel.report.recommendations.indices, id: \.self) { index in
                        HStack {
                            TextField("Doporučení", text: $viewModel.report.recommendations[index])
                            Button {
                                viewModel.report.recommendations.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    Button {
                        viewModel.addRecommendation()
                    } label: {
                        Label("Přidat doporučení", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Doporučení")
                }
                
                // Timeline
                Section {
                    ForEach(viewModel.report.timeline.sorted(by: { $0.date > $1.date }).prefix(10)) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if viewModel.report.timeline.count > 10 {
                        Text("... a \(viewModel.report.timeline.count - 10) dalších událostí")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Časová osa")
                }
                
                // Conclusions
                Section("Závěry") {
                    TextEditor(text: $viewModel.report.conclusions)
                        .frame(minHeight: 100)
                }
                
                // Export Section
                Section {
                    Button {
                        viewModel.exportToPDF()
                    } label: {
                        Label("Exportovat do PDF", systemImage: "doc.fill")
                    }
                    
                    Button {
                        viewModel.exportToJSON()
                    } label: {
                        Label("Exportovat do JSON", systemImage: "doc.text")
                    }
                    
                    Button {
                        viewModel.exportToHTML()
                    } label: {
                        Label("Exportovat do HTML", systemImage: "globe")
                    }
                } header: {
                    Text("Export")
                }
            }
            .navigationTitle("Editor reportu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložit") {
                        viewModel.saveReport()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func severityBadge(_ severity: ReportFinding.Severity) -> some View {
        Text(severity.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(severity.color.opacity(0.2))
            .foregroundStyle(severity.color)
            .clipShape(Capsule())
    }
    
    private func confidenceBadge(_ confidence: Double) -> some View {
        Text("\(Int(confidence * 100))%")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.2))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

// MARK: - Finding Editor

struct FindingEditorView: View {
    @Binding var finding: ReportFinding
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Základní informace") {
                TextField("Název", text: $finding.title)
                TextField("Kategorie", text: $finding.category)
                
                Picker("Závažnost", selection: $finding.severity) {
                    ForEach(ReportFinding.Severity.allCases, id: \.self) { severity in
                        Text(severity.rawValue).tag(severity)
                    }
                }
                
                Toggle("Ověřeno", isOn: $finding.verified)
            }
            
            Section("Popis") {
                TextEditor(text: $finding.description)
                    .frame(minHeight: 100)
            }
            
            Section("Poznámky") {
                TextEditor(text: $finding.notes)
                    .frame(minHeight: 80)
            }
            
            Section {
                ForEach(finding.evidence.indices, id: \.self) { index in
                    TextField("Důkaz", text: $finding.evidence[index])
                }
                .onDelete { indexSet in
                    finding.evidence.remove(atOffsets: indexSet)
                }
                
                Button {
                    finding.evidence.append("")
                } label: {
                    Label("Přidat důkaz", systemImage: "plus.circle")
                }
            } header: {
                Text("Důkazy")
            }
        }
        .navigationTitle("Upravit nález")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Correlation Editor

struct CorrelationEditorView: View {
    @Binding var correlation: CorrelationFinding
    
    var body: some View {
        Form {
            Section("Základní informace") {
                TextField("Cíl 1", text: $correlation.target1Name)
                TextField("Cíl 2", text: $correlation.target2Name)
                TextField("Typ shody", text: $correlation.matchType)
                
                HStack {
                    Text("Jistota")
                    Spacer()
                    Text("\(Int(correlation.confidence * 100))%")
                }
            }
            
            Section("Popis") {
                TextEditor(text: $correlation.description)
                    .frame(minHeight: 100)
            }
            
            Section("Poznámky vyšetřovatele") {
                TextEditor(text: $correlation.investigatorNotes)
                    .frame(minHeight: 80)
            }
            
            Section {
                ForEach(correlation.evidence.indices, id: \.self) { index in
                    TextField("Důkaz", text: $correlation.evidence[index])
                }
                .onDelete { indexSet in
                    correlation.evidence.remove(atOffsets: indexSet)
                }
                
                Button {
                    correlation.evidence.append("")
                } label: {
                    Label("Přidat důkaz", systemImage: "plus.circle")
                }
            } header: {
                Text("Důkazy")
            }
        }
        .navigationTitle("Upravit korelaci")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - View Model

@MainActor
class ReportEditorViewModel: ObservableObject {
    @Published var report: InvestigativeReport
    
    init(report: InvestigativeReport) {
        self.report = report
    }
    
    func addFinding() {
        let finding = ReportFinding(
            category: "Nová kategorie",
            title: "Nový nález",
            severity: .info
        )
        report.findings.append(finding)
    }
    
    func addRecommendation() {
        report.recommendations.append("Nové doporučení")
    }
    
    func saveReport() {
        report.updatedAt = Date()
        // TODO: Persist to storage
    }
    
    func exportToPDF() {
        // TODO: Implement PDF export
        print("Exporting to PDF...")
    }
    
    func exportToJSON() {
        // TODO: Implement JSON export
        print("Exporting to JSON...")
    }
    
    func exportToHTML() {
        // TODO: Implement HTML export
        print("Exporting to HTML...")
    }
}
