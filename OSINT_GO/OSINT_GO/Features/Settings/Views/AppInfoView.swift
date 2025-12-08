//
//  AppInfoView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct AppInfoView: View {
    var body: some View {
        List {
            Section("Atlas OSINT") {
                LabeledContent("Version") {
                    Text("1.0.0")
                }
                LabeledContent("Modules") {
                    Text("12 active")
                }
                LabeledContent("Investigations") {
                    Text("42 stored")
                }
            }
            
            Section("Capabilities") {
                ForEach(TargetType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.iconName)
                        Text(type.rawValue)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .navigationTitle("App Info")
    }
}
