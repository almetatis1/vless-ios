import Foundation
import RevenueCat
import SwiftUI

// MARK: - RevenueCat Manager
@MainActor
class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()
    
    @Published var isSubscribed: Bool = false
    @Published var customerInfo: CustomerInfo?
    
    private init() {}
    
    // Configure RevenueCat with your API key
    func configure() {
        // TODO: Replace with your actual RevenueCat API key
        let apiKey = "appl_BKaJSDIbTkUDNnTeAUKtfWESFzp"
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        // Set up listener for customer info updates
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    // Check current subscription status
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.customerInfo = customerInfo
            
            // Check if user has any active entitlements
            // Replace "premium" with your actual entitlement identifier
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty
            
            print("Subscription status: \(isSubscribed)")
        } catch {
            print("Error fetching customer info: \(error)")
            self.isSubscribed = false
        }
    }
    
    // Restore purchases
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        self.customerInfo = customerInfo
        self.isSubscribed = !customerInfo.entitlements.active.isEmpty
    }
    
    // Get offerings for paywall
    func getOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }
}
