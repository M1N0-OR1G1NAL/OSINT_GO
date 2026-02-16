//
//  AppInfoView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData

struct AppInfoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var investigations: [Investigation]
    
    private var moduleCount: Int {
        OsintModule.allModules.count
    }
    
    var body: some View {
        List {
            Section("Atlas OSINT") {
                LabeledContent("Version") {
                    Text(AppConfig.appVersion)
                }
                LabeledContent("Modules") {
                    Text("\(moduleCount) active")
                }
                LabeledContent("Investigations") {
                    Text("\(investigations.count) stored")
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
