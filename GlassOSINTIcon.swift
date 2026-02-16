    //
    //  GlassOSINTIcon.swift
    //  OSINT
    //
    //  Created by M1N0-H1DDEN on 12.12.2025.
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
                        .stroke(Color.osintAccent.opacity(0.28), lineWidth: 1.5)
                )
                .blur(radius: 8)
                .overlay(
                    RadialGradient(
                        colors: [Color.clear, Color.osintAccent.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .shadow(color: Color.osintAccent.opacity(0.28), radius: 20, x: 0, y: 10)
                .shadow(color: Color.white.opacity(0.12), radius: 8, x: 0, y: -5)
            
                // Main magnifying glass icon with neon-green gradient
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: size * 0.8, weight: .medium))
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color.osintAccent, Color.osintAccent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.clear],
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
                        .frame(width: size * 0.28, height: size * 0.28)
                        .offset(x: size * 0.08, y: -size * 0.08)
                )
            
                // Subtle rotating shine using accent color
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.35), Color.clear],
                        center: .leading,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
        }
        .frame(width: size, height: size)
        .onAppear { isAnimating = true }
        .shadow(color: Color.osintAccent.opacity(0.36), radius: 18, x: 0, y: 8)
    }
}
