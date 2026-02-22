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
    @State private var showingCameraScanner = false

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

                Section {
                    Button {
                        showingCameraScanner = true
                    } label: {
                        Label("Skenovat kamerou", systemImage: "camera.viewfinder")
                    }
                } footer: {
                    Text("Detekuje obličeje, QR kódy, čárové kódy a text. Vše zpracováno lokálně.")
                        .font(.caption)
                }
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
            .sheet(isPresented: $showingCameraScanner) {
                CameraScanView { result in
                    selectedType = result.type
                    value = result.value
                    label = result.label
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
