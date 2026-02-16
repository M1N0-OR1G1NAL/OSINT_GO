//
//  RootGraph3D.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import Foundation
import SceneKit

struct RootGraph3D: Codable, Equatable {
    var nodes: [RootNode3D] = []
    var edges: [RootEdge3D] = []
}

struct RootNode3D: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String = "Bublina"
    var note: String = ""
    var targets: [RootTarget3D] = []

    /// Pozice ve světě (y=0 je “podlaha”)
    var position: Vec3 = .init(0, 0, 0)

    /// Poloměr bubliny (v “metrech” SceneKitu)
    var radius: Float = 0.28
}

struct RootTarget3D: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var text: String = "Target"
    var isDone: Bool = false
}

struct RootEdge3D: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var fromNodeID: UUID
    var toNodeID: UUID
    var label: String = ""
}

/// Jednoduchý codable vektor (bez závislosti na SIMD)
struct Vec3: Codable, Equatable {
    var x: Float
    var y: Float
    var z: Float

    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x; self.y = y; self.z = z
    }

    static let zero = Vec3(0, 0, 0)

    var scn: SCNVector3 { SCNVector3(x, y, z) }
    static func from(_ v: SCNVector3) -> Vec3 { Vec3(v.x, v.y, v.z) }
}
