//
//  NewInvestigationView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData

struct NewInvestigationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var showingTargetForm = false
    @State private var investigation: Investigation?
    @State private var targets: [Target] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Název vyšetřování") {
                    TextField("Např. 'Suspicious Domain Investigation'", text: $name)
                }
                
                Section("Cíle (Targets)") {
                    List {
                        ForEach(targets) { target in
                            HStack {
                                Image(systemName: TargetType(rawValue: target.type)?.iconName ?? "questionmark")
                                VStack(alignment: .leading) {
                                    Text(target.label.isEmpty ? target.value : target.label)
                                    Text(target.type)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteTarget)
                }
                
                Section {
                    Button("Přidat Target") {
                        showingTargetForm = true
                    }
                }
            }
            .navigationTitle("Nové vyšetřování")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vytvořit") {
                        createInvestigation()
                    }
                    .disabled(name.isEmpty || targets.isEmpty)
                }
            }
            .sheet(isPresented: $showingTargetForm) {
                TargetFormView(targets: $targets)
            }
        }
    }
    
    private func createInvestigation() {
        let newInvestigation = Investigation(name: name)
        for target in targets {
            target.investigation = newInvestigation
            modelContext.insert(target)
        }
        modelContext.insert(newInvestigation)
        dismiss()
    }
    
    private func deleteTarget(offsets: IndexSet) {
        targets.remove(atOffsets: offsets)
    }
}
