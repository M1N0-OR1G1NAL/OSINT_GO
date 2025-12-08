//
//  GlassOSINTIcon.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct GlassOSINTIcon: View {
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Glass background circle
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size * 1.4, height: size * 1.4)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1.5)
                )
                .blur(radius: 8)
                .overlay(
                    RadialGradient(
                        colors: [
                            .clear,
                            Color.blue.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .shadow(color: .white.opacity(0.4), radius: 10, x: 0, y: -5)
            
            // Main magnifying glass icon
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: size * 0.8, weight: .medium))
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            Color.blue.opacity(0.9),
                            Color.purple.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.2
                        )
                        .frame(width: size * 0.9, height: size * 0.9)
                )
                .overlay(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: size * 0.3, height: size * 0.3)
                        .offset(x: size * 0.1, y: -size * 0.1)
                )
            
            // Subtle shine effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        center: .leading,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 8)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            isAnimating = true
        }
        .shadow(
            color: Color.blue.opacity(0.4),
            radius: 15,
            x: 0, y: 8
        )
    }
}
