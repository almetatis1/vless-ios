import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var revenueCatManager = RevenueCatManager.shared

    var onSubscribe: () -> Void

    var body: some View {
        // RevenueCat Paywall
        RevenueCatUI.PaywallView()
            .onRestoreCompleted { customerInfo in
                Task {
                    await revenueCatManager.checkSubscriptionStatus()
                    if revenueCatManager.isSubscribed {
                        // Track restored purchase with AppsFlyer
                        await AppsFlyerManager.shared.trackPurchase(customerInfo: customerInfo)
                        onSubscribe()
                        dismiss()
                    }
                }
            }
            .onPurchaseCompleted { customerInfo in
                Task {
                    await revenueCatManager.checkSubscriptionStatus()
                    if revenueCatManager.isSubscribed {
                        // Track purchase with AppsFlyer
                        await AppsFlyerManager.shared.trackPurchase(customerInfo: customerInfo)
                        onSubscribe()
                        dismiss()
                    }
                }
            }
    }
}
