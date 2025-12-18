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
    }
}
