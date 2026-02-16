// Path: AtlasOSINT/Core/Domain/GraphData.swift

import Foundation

struct GraphNode: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let type: String?       // např. "domain", "ip", "email", "company"
    let group: String?      // pro případné clustery
}

struct GraphEdge: Identifiable, Codable, Hashable {
    let id: String
    let from: String
    let to: String
    let label: String?
}

struct GraphData: Codable, Hashable {
    let nodes: [GraphNode]
    let edges: [GraphEdge]

    init(nodes: [GraphNode] = [], edges: [GraphEdge] = []) {
        self.nodes = nodes
        self.edges = edges
    }
}