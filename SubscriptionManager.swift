// Path: AtlasOSINT/Core/Services/SubscriptionManager.swift

import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isPro: Bool = false
    @Published var availableProducts: [Product] = []

    private init() {}

    // IDs produktů z App Store Connect
    private let productIDs = [
        "atlas.pro.monthly",
        "atlas.pro.yearly"
    ]

    /// Načtení produktů z App Store
    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            availableProducts = products.sorted(by: { $0.price < $1.price })
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    /// Aktualizace entitlements – jestli má user aktivní Pro
    func updateEntitlement() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.productType == .autoRenewable,
               productIDs.contains(transaction.productID) {
                hasPro = true
                break
            }
        }

        isPro = hasPro
    }

    /// Nákup předplatného
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    if productIDs.contains(transaction.productID) {
                        isPro = true
                    }
                    await transaction.finish()
                    return true
                } else {
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("❌ Purchase failed: \(error)")
            return false
        }
    }
}