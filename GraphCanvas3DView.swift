//
//  GraphCanvas3DView.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct GraphCanvas3DView: View {
    @ObservedObject var vm: GraphViewModel
    let controller: GraphSceneController

    var body: some View {
        ZStack {
            GraphSceneView(vm: vm, controller: controller)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    Text(vm.statsText)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                .padding([.top, .leading], 12)

                Spacer()

                HStack(spacing: 10) {
                    Text("Tap: výběr • Double-tap: nová bublina • Long-press+drag: přesun • Drag z konektoru: šipka • 2 prsty: kamera")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                .padding([.bottom, .leading], 12)
            }
        }
    }
}
