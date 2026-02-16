//
//  SubscriptionView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct SubscriptionView: View {
    @State private var selectedPlan: SubscriptionPlan = .free
    
    enum SubscriptionPlan: String, CaseIterable {
        case free = "Free"
        case basic = "Basic"
        case professional = "Professional"
        case enterprise = "Enterprise"
        
        var price: String {
            switch self {
            case .free: return "$0"
            case .basic: return "$9.99"
            case .professional: return "$29.99"
            case .enterprise: return "$99.99"
            }
        }
        
        var period: String {
            switch self {
            case .free: return "Forever"
            default: return "/month"
            }
        }
        
        var features: [String] {
            switch self {
            case .free:
                return [
                    "Basic OSINT modules",
                    "5 concurrent requests",
                    "Local data storage",
                    "Manual module execution"
                ]
            case .basic:
                return [
                    "All Free features",
                    "AI OSINT engine",
                    "10 concurrent requests",
                    "Advanced modules (NMAP, PhoneInfoga)",
                    "Priority support"
                ]
            case .professional:
                return [
                    "All Basic features",
                    "AI Info Gathering engine",
                    "AI Correlation engine",
                    "Unlimited concurrent requests",
                    "Cloud sync",
                    "Team collaboration",
                    "Advanced reporting"
                ]
            case .enterprise:
                return [
                    "All Professional features",
                    "Custom AI models",
                    "API access",
                    "Dedicated support",
                    "Custom integrations",
                    "On-premise deployment option",
                    "SLA guarantee"
                ]
            }
        }
        
        var color: Color {
            switch self {
            case .free: return .gray
            case .basic: return .blue
            case .professional: return .purple
            case .enterprise: return .orange
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Plan")
                        .font(.largeTitle.bold())
                    Text("Unlock powerful OSINT capabilities")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                
                // Current plan indicator
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Currently on Free plan")
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Plan cards
                ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                    SubscriptionPlanCard(
                        plan: plan,
                        isSelected: selectedPlan == plan
                    ) {
                        selectedPlan = plan
                    }
                }
                
                // Subscribe button
                if selectedPlan != .free {
                    Button {
                        // Handle subscription
                    } label: {
                        Text("Subscribe to \(selectedPlan.rawValue)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [selectedPlan.color, selectedPlan.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                
                // Terms
                Text("Subscriptions auto-renew monthly. Cancel anytime.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubscriptionPlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.rawValue)
                            .font(.title2.bold())
                            .foregroundStyle(plan.color)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(plan.price)
                                .font(.title.bold())
                            Text(plan.period)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(plan.color)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(plan.color)
                            Text(feature)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? plan.color : .clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? plan.color.opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        SubscriptionView()
    }
}
