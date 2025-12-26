//
//  ContentView.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var vm = GraphViewModel()
    @State private var showingInspector = false

    // Scene controller držíme “živý” (nesmí se vytvářet pořád dokola)
    @State private var controller = GraphSceneController()

    var body: some View {
        NavigationSplitView {
            List(selection: $vm.selectedNodeID) {
                Section("Bubliny") {
                    ForEach(vm.graph.nodes) { n in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(n.title).font(.headline)
                            if !n.note.isEmpty {
                                Text(n.note).font(.caption).lineLimit(1).foregroundStyle(.secondary)
                            }
                        }
                        .tag(n.id as UUID?)
                    }
                }
            }
            .navigationTitle("Roots 3D")
        } detail: {
            GraphCanvas3DView(vm: vm, controller: controller)
                .navigationTitle("Plátno (3D)")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Inspector") { showingInspector = true }
                            .disabled(vm.selectedNodeID == nil)

                        Button("Auto-Layout") { vm.autoLayout() }

                        Button("Reset Camera") { controller.resetCamera(animated: true) }

                        Button(role: .destructive) { vm.deleteSelectedNode() } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(vm.selectedNodeID == nil)
                    }
                }
                .sheet(isPresented: $showingInspector) {
                    NodeInspectorView(vm: vm)
                }
        }
    }
}
