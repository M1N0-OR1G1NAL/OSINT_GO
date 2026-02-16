//
//  NodeInspectorView.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct NodeInspectorView: View {
    @ObservedObject var vm: GraphViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if let id = vm.selectedNodeID, let node = vm.node(id) {
                InspectorForm(node: node) { updated in
                    vm.updateNode(updated)
                }
                .navigationTitle("Inspector")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Zavřít") { dismiss() }
                    }
                }
            } else {
                ContentUnavailableView("Vyber bublinu", systemImage: "cursorarrow.rays")
                    .navigationTitle("Inspector")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Zavřít") { dismiss() }
                        }
                    }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct InspectorForm: View {
    @State var node: RootNode3D
    let onCommit: (RootNode3D) -> Void

    var body: some View {
        Form {
            Section("Bublina") {
                TextField("Název", text: $node.title)
                TextEditor(text: $node.note)
                    .frame(minHeight: 120)

                HStack {
                    Text("Radius")
                    Slider(value: Binding(
                        get: { Double(node.radius) },
                        set: { node.radius = Float($0) }
                    ), in: 0.18...0.55)
                }
            }

            Section("Targety") {
                ForEach($node.targets) { $t in
                    HStack {
                        Toggle(isOn: $t.isDone) { }
                            .labelsHidden()
                        TextField("Text targetu", text: $t.text)
                    }
                }
                .onDelete { idx in
                    node.targets.remove(atOffsets: idx)
                }

                Button {
                    node.targets.append(RootTarget3D(text: "Nový target", isDone: false))
                } label: {
                    Label("Přidat target", systemImage: "plus")
                }
            }
        }
        .onChange(of: node) { _, nv in
            onCommit(nv)
        }
    }
}
