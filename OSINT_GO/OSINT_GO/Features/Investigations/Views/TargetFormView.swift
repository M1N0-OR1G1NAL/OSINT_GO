//
//  TargetFormView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct TargetFormView: View {
    @Binding var targets: [Target]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: TargetType = .domain
    @State private var value = ""
    @State private var label = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Typ cíle", selection: $selectedType) {
                    ForEach(TargetType.allCases) { type in
                        HStack {
                            Image(systemName: type.iconName)
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                TextField("Hodnota (např. example.com)", text: $value)
                TextField("Popisek (volitelný)", text: $label)
            }
            .navigationTitle("Nový Target")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Přidat") {
                        addTarget()
                    }
                    .disabled(value.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addTarget() {
        let newTarget = Target(type: selectedType, value: value.trimmingCharacters(in: .whitespaces), label: label)
        targets.append(newTarget)
        dismiss()
    }
}
