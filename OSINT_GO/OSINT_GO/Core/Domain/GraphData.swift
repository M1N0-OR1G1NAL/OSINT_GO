//
//  GraphData.swift
//  OSINT_GO
//
//  Created by ChatGPT on 2025-12-09.
//

import Foundation

struct GraphNode: Codable, Identifiable, Hashable {
    let id: UUID
    let label: String
    let type: String

    init(id: UUID = UUID(), label: String, type: String) {
        self.id = id
        self.label = label
        self.type = type
    }
}

struct GraphEdge: Codable, Identifiable, Hashable {
    let id: UUID
    let source: UUID
    let target: UUID
    let relation: String

    init(id: UUID = UUID(), source: UUID, target: UUID, relation: String) {
        self.id = id
        self.source = source
        self.target = target
        self.relation = relation
    }
}

struct GraphData: Codable, Hashable {
    var nodes: [GraphNode]
    var edges: [GraphEdge]

    init(nodes: [GraphNode] = [], edges: [GraphEdge] = []) {
        self.nodes = nodes
        self.edges = edges
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
