import Foundation

// MARK: - Localization keys (all strings go through here for 11 locales: en, ar, es, pt-BR, de, fr, he, id, hi, tr, ru)
// Uses LanguageManager.shared.bundle so in-app language switching takes effect immediately.
enum L10n {
    private static var b: Bundle { LanguageManager.shared.bundle }

    // Onboarding
    static var onboardingWelcomeTitle: String { String(localized: "onboarding.welcome.title", bundle: b, comment: "Welcome to FoxyWall") }
    static var onboardingWelcomeSubtitle: String { String(localized: "onboarding.welcome.subtitle", bundle: b, comment: "Privacy companion") }
    static var onboardingVpnTitle: String { String(localized: "onboarding.vpn.title", bundle: b, comment: "VPN Protection") }
    static var onboardingVpnSubtitle: String { String(localized: "onboarding.vpn.subtitle", bundle: b, comment: "Connect servers worldwide") }
    static var onboardingSpeedTitle: String { String(localized: "onboarding.speed.title", bundle: b, comment: "Speed Test") }
    static var onboardingSpeedSubtitle: String { String(localized: "onboarding.speed.subtitle", bundle: b, comment: "Measure download upload") }
    static var onboardingToolsTitle: String { String(localized: "onboarding.tools.title", bundle: b, comment: "Network Tools") }
    static var onboardingToolsSubtitle: String { String(localized: "onboarding.tools.subtitle", bundle: b, comment: "Trace route") }
    static var onboardingReadyTitle: String { String(localized: "onboarding.ready.title", bundle: b, comment: "Ready to Go") }
    static var onboardingReadySubtitle: String { String(localized: "onboarding.ready.subtitle", bundle: b, comment: "No logs") }
    static var onboardingContinue: String { String(localized: "onboarding.continue", bundle: b, comment: "Continue") }
    static var onboardingLegal: String { String(localized: "onboarding.legal", bundle: b, comment: "Privacy Policy and Terms") }

    // General
    static var done: String { String(localized: "general.done", bundle: b, comment: "Done") }
    static var back: String { String(localized: "general.back", bundle: b, comment: "Back") }
    static var refresh: String { String(localized: "general.refresh", bundle: b, comment: "Refresh") }
    static var connect: String { String(localized: "general.connect", bundle: b, comment: "Connect") }
    static var disconnect: String { String(localized: "general.disconnect", bundle: b, comment: "Disconnect") }
    static var connecting: String { String(localized: "general.connecting", bundle: b, comment: "Connecting...") }
    static var encrypt: String { String(localized: "general.encrypt", bundle: b, comment: "Encrypt") }
    static var protected: String { String(localized: "general.protected", bundle: b, comment: "Protected") }
    static var notProtected: String { String(localized: "general.not_protected", bundle: b, comment: "Not Protected") }
    static var selectServer: String { String(localized: "general.select_server", bundle: b, comment: "Select Server") }
    static var selectVpnServer: String { String(localized: "general.select_vpn_server", bundle: b, comment: "Select VPN Server") }
    static var noServersAvailable: String { String(localized: "general.no_servers", bundle: b, comment: "No servers available") }
    static var loadingServers: String { String(localized: "general.loading_servers", bundle: b, comment: "Loading servers...") }
    static var vless: String { String(localized: "general.vless", bundle: b, comment: "VLESS") }
    static var autoSelected: String { String(localized: "general.auto_selected", bundle: b, comment: "Auto-selected") }
    static var serversTabTitle: String { String(localized: "general.servers_tab", bundle: b, comment: "Servers tab") }

    // VPN tab
    static var vpnTabTitle: String { String(localized: "vpn.tab_title", bundle: b, comment: "VPN") }
    static var foxGuardingFrom: String { String(localized: "vpn.fox_guarding", bundle: b, comment: "Fox is guarding from %@") }
    static var connectionNotSecure: String { String(localized: "vpn.connection_not_secure", bundle: b, comment: "Your connection is not secure") }

    // Speed tab
    static var speedTabTitle: String { String(localized: "speed.tab_title", bundle: b, comment: "Speed") }
    static var downloadMbps: String { String(localized: "speed.download_mbps", bundle: b, comment: "Download Mbps") }
    static var uploadMbps: String { String(localized: "speed.upload_mbps", bundle: b, comment: "Upload Mbps") }
    static var ping: String { String(localized: "speed.ping", bundle: b, comment: "Ping") }
    static var jitter: String { String(localized: "speed.jitter", bundle: b, comment: "Jitter") }
    static var ms: String { String(localized: "speed.ms", bundle: b, comment: "ms") }
    static var vpnActiveSpeedNote: String { String(localized: "speed.vpn_active_note", bundle: b, comment: "VPN is active") }
    static var mbps: String { String(localized: "speed.mbps", bundle: b, comment: "Mbps") }
    static var mbpsDownload: String { String(localized: "speed.mbps_download", bundle: b, comment: "Mbps Download") }
    static var mbpsUpload: String { String(localized: "speed.mbps_upload", bundle: b, comment: "Mbps Upload") }
    static var go: String { String(localized: "speed.go", bundle: b, comment: "GO") }
    static var speedTapToMeasure: String { String(localized: "speed.tap_to_measure", bundle: b, comment: "Tap to measure") }
    static var speedTestTitle: String { String(localized: "speed.speed_test", bundle: b, comment: "Speed Test") }

    // Speed test phases
    static var phaseReady: String { String(localized: "speed_phase.ready", bundle: b, comment: "Ready") }
    static var phaseTestingPing: String { String(localized: "speed_phase.testing_ping", bundle: b, comment: "Testing Ping...") }
    static var phaseTestingDownload: String { String(localized: "speed_phase.testing_download", bundle: b, comment: "Testing Download Speed...") }
    static var phaseTestingUpload: String { String(localized: "speed_phase.testing_upload", bundle: b, comment: "Testing Upload Speed...") }
    static var phaseComplete: String { String(localized: "speed_phase.complete", bundle: b, comment: "Complete") }

    // Tools / Traceroute
    static var toolsTabTitle: String { String(localized: "tools.tab_title", bundle: b, comment: "Tools") }
    static var traceToServer: String { String(localized: "tools.trace_to_server", bundle: b, comment: "Trace to current VPN server") }
    static var enterIpOrDomain: String { String(localized: "tools.enter_ip_domain", bundle: b, comment: "Enter an IP or domain to trace the path") }
    static var tracerouteTitle: String { String(localized: "tools.traceroute_title", bundle: b, comment: "Traceroute") }
    static var smartRouteTitle: String { String(localized: "tools.smart_route", bundle: b, comment: "Smart Route") }
    static var enterIpOrDomainShort: String { String(localized: "tools.enter_ip_short", bundle: b, comment: "Enter an IP or domain to trace") }

    // Protection tab
    static var protectionTabTitle: String { String(localized: "protection.tab_title", bundle: b, comment: "Protection") }
    static var vpnProtection: String { String(localized: "protection.vpn_protection", bundle: b, comment: "VPN Protection") }
    static var connected: String { String(localized: "protection.connected", bundle: b, comment: "Connected") }
    static var disconnected: String { String(localized: "protection.disconnected", bundle: b, comment: "Disconnected") }
    static var connectVpn: String { String(localized: "protection.connect_vpn", bundle: b, comment: "Connect VPN") }
    static var disconnectVpn: String { String(localized: "protection.disconnect_vpn", bundle: b, comment: "Disconnect VPN") }

    // Settings
    static var settingsTabTitle: String { String(localized: "settings.tab_title", bundle: b, comment: "Settings") }
    static var subscriptions: String { String(localized: "settings.subscriptions", bundle: b, comment: "Subscriptions") }
    static var manageSubscription: String { String(localized: "settings.manage_subscription", bundle: b, comment: "Manage your premium subscription") }
    static var redeemCode: String { String(localized: "settings.redeem_code", bundle: b, comment: "Redeem Offer Code") }
    static var enterPromoCode: String { String(localized: "settings.enter_promo", bundle: b, comment: "Enter a promo or offer code") }
    static var appearance: String { String(localized: "settings.appearance", bundle: b, comment: "Appearance") }
    static var light: String { String(localized: "settings.light", bundle: b, comment: "Light") }
    static var dark: String { String(localized: "settings.dark", bundle: b, comment: "Dark") }
    static var privacyPolicy: String { String(localized: "settings.privacy_policy", bundle: b, comment: "Privacy Policy") }
    static var termsOfUse: String { String(localized: "settings.terms_of_use", bundle: b, comment: "Terms of Use") }
    static var appName: String { String(localized: "settings.app_name", bundle: b, comment: "App Name") }
    static var appNameValue: String { String(localized: "settings.app_name_value", bundle: b, comment: "FoxyWall") }
    static var version: String { String(localized: "settings.version", bundle: b, comment: "Version") }
    static var versionValue: String { String(localized: "settings.version_value", bundle: b, comment: "2.11") }
    static var localIpAddress: String { String(localized: "settings.local_ip", bundle: b, comment: "Local IP Address") }
    static var deviceInfo: String { String(localized: "settings.device_info", bundle: b, comment: "Device Info") }
    static var eulaTitle: String { String(localized: "settings.eula_title", bundle: b, comment: "End User License Agreement") }
    static var settingsLanguage: String { String(localized: "settings.language", bundle: b, comment: "Language") }
    static var profileTitle: String { String(localized: "settings.profile", bundle: b, comment: "Profile") }

    // Errors / status
    static var statusConnectingFormat: String { String(localized: "status.connecting_format", bundle: b, comment: "Connecting to %@") }
    static func statusConnecting(_ serverName: String) -> String {
        String(format: statusConnectingFormat, serverName)
    }
    static var statusSelectServerFirst: String { String(localized: "status.select_server_first", bundle: b, comment: "Please select a server first") }
    static var statusServerCredentialsNotAvailable: String { String(localized: "status.server_credentials", bundle: b, comment: "Server credentials not available") }
    static var statusVpnSimulator: String { String(localized: "status.vpn_simulator", bundle: b, comment: "VPN not available in simulator") }
    static var statusFailedLoadServers: String { String(localized: "status.failed_load_servers", bundle: b, comment: "Failed to load servers") }
    static var statusLoadedServersFormat: String { String(localized: "status.loaded_servers_format", bundle: b, comment: "Loaded N VPN servers") }
    static func statusLoadedServers(_ count: Int) -> String {
        String(format: statusLoadedServersFormat, count)
    }
}
