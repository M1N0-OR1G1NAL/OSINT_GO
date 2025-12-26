//
//  GraphData.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import Foundation

struct GraphData: Codable {
    var nodes: [GraphNodeData] = []
    var edges: [GraphEdge] = []
    var layout: GraphLayout = .circular
    
    enum GraphLayout: String, Codable {
        case circular
        case hierarchical
        case force
    }
}

struct GraphNodeData: Codable, Identifiable {
    let id: String
    var x: Double = 0
    var y: Double = 0
    var label: String
    var type: String
    var metadata: [String: String] = [:]
}

struct GraphEdge: Codable, Identifiable {
    let id: String
    let source: String
    let target: String
    var weight: Double = 1.0
    var label: String = ""
    
    init(source: String, target: String, weight: Double = 1.0, label: String = "") {
        self.id = "\(source)-\(target)"
        self.source = source
        self.target = target
        self.weight = weight
        self.label = label
    }
}
