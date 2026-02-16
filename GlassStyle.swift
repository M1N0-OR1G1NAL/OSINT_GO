    // filepath: /Library/Developer/X-Code/OSINT/OSINT/CommonUI/GlassStyle.swift

import SwiftUI

    // Color palette constants matching provided CSS
extension Color {
    static let osintBg = Color(red: 0.01, green: 0.02, blue: 0.01)
    static let osintPanel = Color.black.opacity(0.85)
    static let osintAccent = Color(red: 0.24, green: 1.0, blue: 0.47) // #3cff78 analog
    static let osintAccentSoft = Color(red: 0.24, green: 1.0, blue: 0.47).opacity(0.2)
    static let osintText = Color(red: 0.72, green: 1.0, blue: 0.81)
}

    // Reusable glassy background with animated glows and subtle vignette
struct GlassBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.osintBg, Color.black]), center: .topLeading, startRadius: 5, endRadius: 800)
                .ignoresSafeArea()
            
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.02), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.osintAccent.opacity(0.06))
                .frame(width: 700, height: 700)
                .blur(radius: animate ? 60 : 140)
                .offset(x: animate ? -120 : 180, y: animate ? -200 : 120)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }
        }
    }
}

    // Glass card used for panels
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 12
    var bodyColor: Color = Color.black.opacity(0.35)
    
    init(cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [bodyColor, Color.black.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.osintAccent.opacity(0.18), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: Color.osintAccent.opacity(0.08), radius: 30, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.osintAccent.opacity(0.03), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
            
            content
                .padding()
        }
    }
}

    // Glass tab button with active state and animations
struct GlassTabButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(
                Group {
                    if isActive {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(LinearGradient(colors: [Color.osintAccent.opacity(0.95), Color.osintAccent.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.osintAccent.opacity(0.5), radius: 18, x: 0, y: 6)
                    } else {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(Color.black.opacity(0.25))
                            .overlay(RoundedRectangle(cornerRadius: 999).stroke(Color.osintAccent.opacity(0.12), lineWidth: 1))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isActive ? Color.black : Color.white)
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isActive)
    }
}

    // Glass header used in InvestigationDetailView
struct GlassHeader: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.osintText)
                    .shadow(color: Color.osintAccent.opacity(0.22), radius: 8, x: 0, y: 2)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            Spacer()
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.largeTitle)
                .foregroundColor(Color.osintAccent.opacity(0.95))
                .shadow(color: Color.osintAccent.opacity(0.18), radius: 12, x: 0, y: 6)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.osintAccent.opacity(0.08), lineWidth: 1))
    }
}

    // Small helper modifier for glassy card titles
struct GlassTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.title2, design: .rounded).bold())
            .foregroundColor(Color.osintText)
            .shadow(color: Color.osintAccent.opacity(0.25), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func glassTitle() -> some View {
        self.modifier(GlassTitle())
    }
}

#if DEBUG
struct GlassStyle_Previews: PreviewProvider {
    static var previews: some View {
        GlassBackground()
            .overlay(
                GlassCard {
                    VStack {
                        Text("Hello, OSINT!")
                            .glassTitle()
                        Text("Welcome to the glassy world of SwiftUI.")
                            .foregroundColor(.white)
                            .padding(.top, 2)
                    }
                    .padding()
                }
                    .padding()
                    .frame(width: 300)
            )
    }
}
#endif
