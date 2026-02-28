import Foundation
import AppsFlyerLib
import RevenueCat

// MARK: - AppsFlyer Manager
@MainActor
class AppsFlyerManager: NSObject, ObservableObject {
    static let shared = AppsFlyerManager()

    // TODO: Replace with your actual AppsFlyer Dev Key and App ID
    private let devKey = "GbYoDDZzgatShWKfu2nwiJ"
    private let appID = "id6757646633"

    private override init() {
        super.init()
    }

    // Configure AppsFlyer SDK
    func configure() {
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appID
        AppsFlyerLib.shared().delegate = self

        // Enable debug mode for development (disable in production)
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif

        // Start the SDK
        AppsFlyerLib.shared().start()

        print("AppsFlyer configured and started")
    }

    // Track purchase event with RevenueCat CustomerInfo
    func trackPurchase(customerInfo: CustomerInfo) {
        guard let latestTransaction = customerInfo.nonSubscriptions.last else {
            // Check for subscription purchases
            if let activeEntitlement = customerInfo.entitlements.active.values.first {
                trackSubscriptionPurchase(entitlement: activeEntitlement)
            }
            return
        }

        // Track non-subscription purchase
        let eventValues: [String: Any] = [
            AFEventParamContentId: latestTransaction.productIdentifier,
            AFEventParamContentType: "non_subscription",
            AFEventParamQuantity: 1
        ]

        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: eventValues)
        print("AppsFlyer: Tracked non-subscription purchase - \(latestTransaction.productIdentifier)")
    }

    // Track subscription purchase
    func trackSubscriptionPurchase(entitlement: EntitlementInfo) {
        let eventValues: [String: Any] = [
            AFEventParamContentId: entitlement.productIdentifier,
            AFEventParamContentType: "subscription",
            "entitlement_id": entitlement.identifier,
            AFEventParamQuantity: 1
        ]

        AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: eventValues)
        print("AppsFlyer: Tracked subscription purchase - \(entitlement.productIdentifier)")
    }

    // Track purchase with specific product and revenue details
    func trackPurchase(productId: String, price: Double, currency: String, transactionId: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: price,
            AFEventParamCurrency: currency,
            AFEventParamQuantity: 1
        ]

        if let transactionId = transactionId {
            eventValues[AFEventParamOrderId] = transactionId
        }

        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: eventValues)
        print("AppsFlyer: Tracked purchase - Product: \(productId), Revenue: \(price) \(currency)")
    }

    // Track subscription with revenue
    func trackSubscription(productId: String, price: Double, currency: String, transactionId: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: price,
            AFEventParamCurrency: currency,
            AFEventParamQuantity: 1
        ]

        if let transactionId = transactionId {
            eventValues[AFEventParamOrderId] = transactionId
        }

        AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: eventValues)
        print("AppsFlyer: Tracked subscription - Product: \(productId), Revenue: \(price) \(currency)")
    }

    // Track custom event
    func trackEvent(name: String, values: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(name, withValues: values)
        print("AppsFlyer: Tracked event - \(name)")
    }

    // Set customer user ID (useful for linking with RevenueCat)
    func setCustomerUserId(_ userId: String) {
        AppsFlyerLib.shared().customerUserID = userId
        print("AppsFlyer: Set customer user ID - \(userId)")
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppsFlyerManager: AppsFlyerLibDelegate {
    nonisolated func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("AppsFlyer: Conversion data success")
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                if let sourceID = conversionInfo["media_source"],
                   let campaign = conversionInfo["campaign"] {
                    print("AppsFlyer: Non-organic install from \(sourceID) - Campaign: \(campaign)")
                }
            } else {
                print("AppsFlyer: Organic install")
            }
        }
    }

    nonisolated func onConversionDataFail(_ error: Error) {
        print("AppsFlyer: Conversion data failed - \(error.localizedDescription)")
    }
}
