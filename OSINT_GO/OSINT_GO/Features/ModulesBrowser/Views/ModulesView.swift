//
//  ModulesView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct ModulesView: View {
    @StateObject private var viewModel = ModulesViewModel()
    @State private var selectedTarget: Target?

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        GlassHeader(title: "OSINT Modules", subtitle: "Run single modules or full playbooks")

                        GlassModulesSection(
                            title: "Domain & IP",
                            modules: [viewModel.domainIpModule, viewModel.dnsModule, viewModel.whoisModule],
                            selectedTarget: $selectedTarget
                        )

                        GlassModulesSection(
                            title: "Email & Username",
                            modules: [viewModel.emailModule, viewModel.usernameModule],
                            selectedTarget: $selectedTarget
                        )

                        GlassModulesSection(
                            title: "Company & Phone",
                            modules: [viewModel.companyModule, viewModel.phoneModule],
                            selectedTarget: $selectedTarget
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Modules")
        }
    }
}

struct GlassHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 14)
    }
}

struct GlassModulesSection: View {
    let title: String
    let modules: [OsintModule]
    @Binding var selectedTarget: Target?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            ForEach(modules.indices, id: \.self) { idx in
                GlassModuleRow(module: modules[idx], selectedTarget: $selectedTarget)
            }
        }
    }
}

struct GlassModuleRow: View {
    let module: OsintModule
    @Binding var selectedTarget: Target?
    @State private var isPressed = false
    @State private var showingTargetPicker = false
    
    var body: some View {
        Button {
            showingTargetPicker = true
        } label: {
            HStack {
                Image(systemName: module.iconName)
                    .font(.title2)
                    .foregroundStyle(module.color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(module.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .buttonStyle(.plain)
        .alert("Select Target", isPresented: $showingTargetPicker) {
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please create a target in an investigation first to run this module.")
        }
    }
}

#Preview {
    ModulesView()
}

