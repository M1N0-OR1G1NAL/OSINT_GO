//
//  GraphTabView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct GraphTabView: View {
    let investigation: Investigation
    
    var body: some View {
        VStack {
            if investigation.targets.isEmpty {
                EmptyStateView(
                    title: "Žádný graf",
                    message: "Přidej targets a spusť OSINT moduly pro vizualizaci vztahů",
                    icon: "chart.xyaxis.line"
                )
            } else {
                GeometryReader { geo in
                    ZStack {
                        // Background connections
                        ForEach(connectionLines(for: geo.size)) { line in
                            Path { path in
                                path.move(to: line.from)
                                path.addLine(to: line.to)
                            }
                            .stroke(line.color.opacity(0.3), lineWidth: 2)
                        }
                        
                        // Nodes
                        ForEach(nodes(for: geo.size)) { node in
                            NodeView(node: node)
                                .position(node.position)
                        }
                    }
                }
            }
        }
        .frame(height: 400)
    }
    
    private func nodes(for size: CGSize) -> [GraphNode] {
        let count = investigation.targets.count
        let radius = min(size.width, size.height) * 0.3
        var nodes: [GraphNode] = []
        
        for (index, target) in investigation.targets.enumerated() {
            let angle = Double(index) * 2 * .pi / Double(count)
            let x = size.width / 2 + radius * cos(angle)
            let y = size.height / 2 + radius * sin(angle)
            
            let risk = target.results.reduce(0) { $0 + $1.riskScore } / Double(target.results.count.max(1))
            
            nodes.append(GraphNode(
                id: target.id.uuidString,
                title: target.value,
                risk: risk,
                position: CGPoint(x: x, y: y),
                type: TargetType(rawValue: target.type) ?? .domain
            ))
        }
        return nodes
    }
    
    private func connectionLines(for size: CGSize) -> [GraphLine] {
        // Simplified connections
        var lines: [GraphLine] = []
        let nodes = self.nodes(for: size)
        for i in 0..<nodes.count {
            for j in i+1..<nodes.count {
                lines.append(GraphLine(
                    from: nodes[i].position,
                    to: nodes[j].position,
                    strength: 0.3
                ))
            }
        }
        return lines.prefix(10).map { $0 }
    }
}

struct GraphNode: Identifiable {
    let id: String
    let title: String
    let risk: Double
    let position: CGPoint
    let type: TargetType
}

struct GraphLine {
    let from: CGPoint
    let to: CGPoint
    let strength: Double
    var color: Color { .blue }
}

struct NodeView: View {
    let node: GraphNode
    
    var body: some View {
        VStack(spacing: 4) {
            RiskBadgeView(score: node.risk)
                .scaleEffect(0.8)
            Text(node.title)
                .font(.caption)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}
