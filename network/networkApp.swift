import SwiftUI
import RevenueCat
import CoreLocation
import MapKit
import UniformTypeIdentifiers
import NetworkExtension
import Security
import Foundation
import Network
import NetworkExtension


@main
struct NetworkApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                NetworkView()
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}

// MARK: - Fox Mascot View
enum FoxMascotState {
    case idle
    case connecting
    case connected
    case speedReady
    case tracing
    case traceDone
}

struct FoxMascotView: View {
    let state: FoxMascotState

    private var imageName: String {
        switch state {
        case .idle: return "pawprint.fill"
        case .connecting: return "pawprint.circle"
        case .connected: return "pawprint.circle.fill"
        case .speedReady: return "pawprint.fill"
        case .tracing: return "pawprint.fill"
        case .traceDone: return "pawprint.circle.fill"
        }
    }

    var body: some View {
        Image(systemName: imageName)
            .font(.system(size: 56))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }
}

struct NetworkView: View {
    @State private var isLoading = false
    @State private var statusMessage = ""
    @State private var isConnected = false
    @State private var showingCredentialAlert = false

    @State private var showingSettings = false
    @State private var showingServerSelector = false
    
    // Supabase VPN servers
    @State private var vpnServers: [VPNServer] = []
    @State private var selectedServer: VPNServer? = nil
    @State private var isLoadingServers = false
    
    // Tab navigation
    @State private var selectedTab: AppTab = .vpn
    @State private var showingVPNSheet = false
    @State private var tracerouteDestination: String = ""

    // RevenueCat
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showingPaywall = false

    // Appearance
    @AppStorage("appTheme") private var appTheme: String = "dark"

    // Network Security Services
    @StateObject private var pingService = PingService()
    @StateObject private var tracerouteService = TracerouteService()
    @StateObject private var speedTestService = SpeedTestService()
    
    // MARK: - VPN Configuration
    private let defaultServerAddress = "69.197.134.25"
    private let defaultUsername = "XXX"       // Use the correct VPN server credentials
    private let defaultPassword = "XXX"     // Use the correct VPN server credentials
    private let defaultSharedSecret = "ipsec-vpn-key"
    
    // VPN server ports
    private let vpnServerPort = 500  // IPSec IKE port
    private let vpnServerPort2 = 4500  // IPSec NAT-T port
    
    // Constants for Keychain identifiers
    private let kKeychainVPNUsernameKey = "com.foxywall.username"
    private let kKeychainVPNPasswordKey = "com.foxywall.password"
    private let kKeychainVPNSharedSecretKey = "com.foxywall.sharedsecret"
    private let kKeychainVPNServerAddressKey = "com.foxywall.serveraddress"
    
    private var backgroundColor: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            Tab("VPN", systemImage: "globe", value: .vpn) {
                vpnTabContent
            }

            Tab("Speed", systemImage: "speedometer", value: .scanner) {
                speedTestTabContent
            }

            Tab("Tools", systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill", value: .tools) {
                toolsTabContent
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                settingsTabContent2
            }
        }
        .preferredColorScheme(appTheme == "light" ? .light : .dark)
        .tabViewStyle(.sidebarAdaptable)
        .sheet(isPresented: $showingServerSelector) {
            SupabaseServerSelectorView(
                selectedServer: $selectedServer,
                vpnServers: vpnServers,
                isLoadingServers: isLoadingServers,
                onRefresh: fetchVPNServers
            )
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView {
                setupAndConnectVPN()
            }
        }
        .fullScreenCover(isPresented: $showingVPNSheet) {
            vpnScreenContent
        }
        .onAppear {
            revenueCatManager.configure()
            AppsFlyerManager.shared.configure()
            checkVPNStatus()
            fetchVPNServers()
        }
    }
    
    // MARK: - Tab Content Views

    /// Speed tab: Speedtest-style gauge with download/upload/ping/jitter.
    private var speedTestTabContent: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Download / Upload header
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.cyan)
                                    .font(.caption)
                                Text("Download Mbps")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            Text(speedTestService.currentResult != nil
                                 ? String(format: "%.2f", speedTestService.currentResult!.downloadSpeedMbps)
                                 : "—")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)

                        Divider().frame(height: 40)

                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.cyan)
                                    .font(.caption)
                                Text("Upload Mbps")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            Text(speedTestService.currentResult != nil
                                 ? String(format: "%.2f", speedTestService.currentResult!.uploadSpeedMbps)
                                 : "—")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)

                    // Ping & Jitter row
                    HStack(spacing: 24) {
                        HStack(spacing: 6) {
                            Text("Ping")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("ms")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(speedTestService.currentResult != nil
                                 ? String(format: "%.0f", speedTestService.currentResult!.pingMs)
                                 : "—")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }

                        HStack(spacing: 6) {
                            Text("Jitter")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("ms")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(speedTestService.currentResult != nil
                                 ? String(format: "%.0f", speedTestService.currentResult!.jitterMs)
                                 : "—")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Gauge (tappable — starts/restarts test)
                    Button(action: {
                        if !speedTestService.isRunning {
                            speedTestService.runSpeedTest()
                        }
                    }) {
                        SpeedtestGaugeView(
                            currentSpeed: speedTestService.isRunning
                                ? speedTestService.currentSpeed
                                : (speedTestService.currentResult?.downloadSpeedMbps ?? 0),
                            isRunning: speedTestService.isRunning,
                            hasResult: speedTestService.currentResult != nil,
                            phase: speedTestService.currentPhase,
                            speedText: speedTestService.isRunning
                                ? String(format: "%.2f", speedTestService.currentSpeed)
                                : (speedTestService.currentResult != nil
                                    ? String(format: "%.2f", speedTestService.currentResult!.downloadSpeedMbps)
                                    : nil)
                        )
                        .frame(height: 260)
                    }
                    .buttonStyle(.plain)
                    .disabled(speedTestService.isRunning)
                    .padding(.top, 30)
                    .padding(.horizontal, 40)

                    if isConnected && !speedTestService.isRunning {
                        Text("VPN is active · results reflect protected speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("Speed")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Firewall Screen Content
    private var vpnScreenContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Firewall Status Card
                VStack(spacing: 24) {
                    // Large shield icon
                    ZStack {
                        Circle()
                            .fill(isConnected ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                            .frame(width: 140, height: 140)

                        Image(systemName: isConnected ? "flame.fill" : "flame")
                            .font(.system(size: 70))
                            .foregroundColor(isConnected ? .green : .gray)
                    }

                    Text(isConnected ? "Protected" : "Not Protected")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Encrypt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Bottom section
                VStack(spacing: 16) {
                    // Connect/Disconnect Button
                    Button(action: {
                        if isConnected {
                            disconnectVPN()
                        } else {
                            setupAndConnectVPN()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: isConnected ? "power" : "bolt.shield.fill")
                            }
                            Text(isLoading ? "Connecting..." : (isConnected ? "Disconnect" : "Connect"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: isConnected ? [.red, .red.opacity(0.8)] : [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingVPNSheet = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }

    private func getLocalIPAddress() -> String {
        var address: String = "Unknown"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return address }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: (interface?.ifa_name)!)
                if name == "en0" || name == "en1" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                    address = String(cString: hostname)
                    break
                }
            }
        }
        return address
    }

    private func scoreGradientColors(score: Int) -> [Color] {
        if score >= 80 {
            return [.green, .green.opacity(0.7)]
        } else if score >= 60 {
            return [.yellow, .yellow.opacity(0.7)]
        } else if score >= 40 {
            return [.orange, .orange.opacity(0.7)]
        } else {
            return [.red, .red.opacity(0.7)]
        }
    }
    
    private func scoreDescription(score: Int) -> String {
        if score >= 80 {
            return "Excellent - Your network is well secured"
        } else if score >= 60 {
            return "Good - Minor security improvements recommended"
        } else if score >= 40 {
            return "Fair - Several security issues detected"
        } else {
            return "Poor - Immediate action required"
        }
    }
    
    private func findingCard(finding: SecurityFinding) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: finding.category.icon)
                    .foregroundColor(severityColor(finding.severity))
                
                Text(finding.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(finding.severity.label)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor(finding.severity).opacity(0.2))
                    .foregroundColor(severityColor(finding.severity))
                    .cornerRadius(8)
            }
            
            Text(finding.description)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text("💡 \(finding.recommendation)")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .glassCard()
        .padding(.horizontal, 20)
    }
    
    private func severityColor(_ severity: SecurityFinding.Severity) -> Color {
        switch severity {
        case .safe: return .green
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    // VPN Tab — redesigned with fox mascot, status, connect button, server chip
    private var vpnTabContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Fox mascot
                FoxMascotView(state: isLoading ? .connecting : (isConnected ? .connected : .idle))
                    .padding(.bottom, 8)

                // Status headline + subtitle
                VStack(spacing: 6) {
                    Text(isLoading ? "Connecting..." : (isConnected ? "Protected" : "Not Protected"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isConnected ? .green : .primary)
                        .animation(.easeInOut(duration: 0.3), value: isConnected)

                    if let server = selectedServer, isConnected {
                        Text("Fox is guarding from \(server.city)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if !isConnected && !isLoading {
                        Text("Your connection is not secure")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                Spacer()

                VStack(spacing: 14) {
                    // Connect / Disconnect button
                    Button(action: {
                        if isConnected { disconnectVPN() } else { setupAndConnectVPN() }
                    }) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: isConnected ? "power" : "bolt.shield.fill")
                            }
                            Text(isLoading ? "Connecting..." : (isConnected ? "Disconnect" : "Connect"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isConnected
                                    ? [.red, .red.opacity(0.85)]
                                    : [Color(red: 0.91, green: 0.46, blue: 0.17), Color(red: 0.77, green: 0.36, blue: 0.07)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading)
                    .accessibilityLabel(isConnected ? "Disconnect VPN" : "Connect to VPN")
                    .accessibilityHint("Double tap to \(isConnected ? "disconnect" : "connect")")

                    // Server chip
                    Button(action: { showingServerSelector = true }) {
                        HStack(spacing: 10) {
                            if let server = selectedServer {
                                Text(server.flag)
                                    .font(.title3)
                                Text("\(server.name) - \(server.city)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            } else {
                                Image(systemName: "globe")
                                    .foregroundColor(.secondary)
                                Text("Select Server")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select VPN server")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("VPN")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Tools Tab (Traceroute)
    private var toolsTabContent: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Enter IP or domain", text: $tracerouteDestination)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .submitLabel(.go)
                            .onSubmit {
                                if !tracerouteService.isRunning && !tracerouteDestination.isEmpty {
                                    tracerouteService.traceroute(to: tracerouteDestination)
                                }
                            }

                        if tracerouteService.isRunning {
                            ProgressView()
                        } else if !tracerouteDestination.isEmpty {
                            Button(action: {
                                tracerouteService.traceroute(to: tracerouteDestination)
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.91, green: 0.46, blue: 0.17))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)

                    // Trace to current VPN server shortcut
                    if let server = selectedServer {
                        Button(action: {
                            tracerouteDestination = server.serverAddress
                            tracerouteService.traceroute(
                                to: server.serverAddress,
                                targetCoordinate: server.coordinate
                            )
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                    .foregroundColor(Color(red: 0.91, green: 0.46, blue: 0.17))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Trace to current VPN server")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("\(server.flag) \(server.city) · \(server.serverAddress)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }

                    // Empty state / fox
                    if tracerouteService.hops.isEmpty && !tracerouteService.isRunning {
                        VStack(spacing: 16) {
                            FoxMascotView(state: .tracing)
                                .frame(height: 120)
                            Text("Enter an IP or domain to trace the path")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 40)
                    } else {
                        // Map of hops
                        if !tracerouteService.hops.isEmpty {
                            TracerouteMapView(hops: tracerouteService.hops)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 20)
                        }

                        // Hop list
                        LazyVStack(spacing: 0) {
                            ForEach(Array(tracerouteService.hops.enumerated()), id: \.element.id) { index, hop in
                                HStack(spacing: 12) {
                                    // Hop number badge
                                    Text("\(hop.hopNumber)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(hop.status == .timeout ? Color.orange : Color.blue)
                                        .clipShape(Circle())

                                    if let flag = hop.flagEmoji {
                                        Text(flag)
                                            .font(.title3)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(hop.host)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        if let ip = hop.ip {
                                            Text(ip)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if let latency = hop.latencyMs {
                                        Text(String(format: "%.0f ms", latency))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(latency < 50 ? .green : (latency < 100 ? .orange : .red))
                                    } else if hop.status == .timeout {
                                        Text("* * *")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Hop \(hop.hopNumber), \(hop.host)\(hop.ip.map { ", \($0)" } ?? "")\(hop.latencyMs.map { ", \(Int($0)) milliseconds" } ?? "")")

                                if index < tracerouteService.hops.count - 1 {
                                    Divider().padding(.leading, 60)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)

                        // Fox done state
                        if !tracerouteService.isRunning && !tracerouteService.hops.isEmpty {
                            FoxMascotView(state: .tracing)
                                .frame(height: 80)
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.top, 10)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground).opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // Activate VPN with traceroute animation
    private func activateVPNWithTraceroute() {
        if isConnected {
            // Disconnect VPN
            disconnectVPN()
            return
        }

        guard let server = selectedServer else {
            statusMessage = "Please select a server first"
            return
        }

        // Run traceroute to server address first (this shows the animation)
        tracerouteService.traceroute(to: server.serverAddress, targetCoordinate: server.coordinate)

        // Connect VPN after traceroute completes
        Task {
            // Wait for traceroute to finish
            while tracerouteService.isRunning {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }

            // Now connect VPN
            await MainActor.run {
                setupAndConnectVPN()
            }
        }
    }

    // Speed Tab - Speed Test + Ping
    // This content has been merged into scannerTabContent
    
    private var pingToolView: some View {
        VStack(spacing: 0) {
            if !pingService.results.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(pingService.results) { result in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.host)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                if let ip = result.ip {
                                    Text(ip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let latency = result.latencyMs {
                                Text(String(format: "%.0f ms", latency))
                                    .font(.headline)
                                    .foregroundColor(.green)
                            } else {
                                Text(result.status.description)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .glassCard()
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            Spacer().frame(height: 20)
            
            Button(action: {
                if pingService.isRunning {
                    pingService.stopPing()
                } else {
                    pingService.pingMultipleHosts(hosts: PingService.commonHosts)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: pingService.isRunning ? "stop.fill" : "play.fill")
                    Text(pingService.isRunning ? "Stop" : "Start Ping Test")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.secondarySystemFill))
                .foregroundColor(.primary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var tracerouteToolView: some View {
        VStack(spacing: 10) {
            if !tracerouteService.hops.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(tracerouteService.hops) { hop in
                        HStack {
                            Text("\(hop.hopNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                            
                            if let flag = hop.flagEmoji {
                                Text(flag)
                                    .font(.title3)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(hop.host)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                if let ip = hop.ip {
                                    Text(ip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if let latency = hop.latencyMs {
                                Text(String(format: "%.0f ms", latency))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("*")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .glassCard()
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            Spacer().frame(height: 20)
            

        }
    }
    
    private var speedTestToolView: some View {
        VStack(spacing: 10) {
            if speedTestService.isRunning {
                VStack(spacing: 8) {
                    ProgressView(value: speedTestService.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    Text(speedTestService.currentPhase.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
            }
            
            if let result = speedTestService.currentResult {
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text(String(format: "%.1f", result.downloadSpeedMbps))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Mbps Download")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text(String(format: "%.1f", result.uploadSpeedMbps))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Mbps Upload")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .glassCard()
                .padding(.horizontal, 20)
            }
        }
    }
    // Protect Tab - Simplified VPN + Security Features
    private var protectTabContent: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // VPN Protection
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VPN Protection")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundColor(isConnected ? .green : .secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if let server = selectedServer {
                        HStack(spacing: 12) {
                            Text(server.flag).font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(server.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                Text("Auto-selected")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    
                    Button(action: isConnected ? disconnectVPN : setupAndConnectVPN) {
                        HStack(spacing: 12) {
                            Image(systemName: "power")
                            Text(isConnected ? "Disconnect" : "Connect VPN")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: isConnected ? [Color.red, Color.red.opacity(0.8)] : [Color.green, Color.green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                }
                .glassCard()
                .padding(.horizontal, 20)
                

                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(width: geometry.size.width)
                }
            }
            .navigationTitle("Protection")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var settingsTabContent2: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Subscriptions
                    Button(action: {
                        showingPaywall = true
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Subscriptions")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Manage your premium subscription")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Redeem Offer Code
                    Button(action: {
                        Purchases.shared.presentCodeRedemptionSheet()
                        Task {
                            await revenueCatManager.checkSubscriptionStatus()
                        }
                    }) {
                        HStack {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.cyan)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Redeem Offer Code")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Enter a promo or offer code")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Theme Switcher
                    HStack(spacing: 12) {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.purple)
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Picker("Theme", selection: $appTheme) {
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                    }
                    .padding(16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)

                    // Privacy Policy
                    Button(action: {
                        if let url = URL(string: "https://www.holylabs.net/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Terms of Use
                    Button(action: {
                        if let url = URL(string: "https://www.holylabs.net/terms") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                            Text("Terms of Use")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    // App Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("App Name")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("FoxyWall")
                                .foregroundColor(.primary)
                        }
                        Divider()
                        HStack {
                            Text("Version")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("2.10")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func saveDefaultCredentials() {
        // Clear existing credentials first
        clearVPNCredentials()
        
        // Store the default credentials in the Keychain
        let usernameSaved = saveToKeychain(key: kKeychainVPNUsernameKey, data: defaultUsername.data(using: .utf8)!)
        let passwordSaved = saveToKeychain(key: kKeychainVPNPasswordKey, data: defaultPassword.data(using: .utf8)!)
        let sharedSecretSaved = saveToKeychain(key: kKeychainVPNSharedSecretKey, data: defaultSharedSecret.data(using: .utf8)!)
        let serverAddressSaved = saveToKeychain(key: kKeychainVPNServerAddressKey, data: defaultServerAddress.data(using: .utf8)!)
        
        statusMessage = "VPN credentials configured"
    }
    
    private func clearVPNCredentials() {
        // Clear all VPN-related keychain items
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: kKeychainVPNUsernameKey
        ] as CFDictionary)
        
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: kKeychainVPNPasswordKey
        ] as CFDictionary)
        
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: kKeychainVPNSharedSecretKey
        ] as CFDictionary)
        
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: kKeychainVPNServerAddressKey
        ] as CFDictionary)
        

    }
    
    private func checkVPNStatus() {
        // VPN is available on both iOS and macOS
        
        let vpnManager = NEVPNManager.shared()
        vpnManager.loadFromPreferences { error in
            if let error = error {
                DispatchQueue.main.async {
                    // Handle simulator-specific VPN errors gracefully
                    if error.localizedDescription.contains("IPC failed") || 
                       error.localizedDescription.contains("Connection invalid") {
                        self.statusMessage = "VPN not available in simulator - use real device for VPN testing"
                    } else {
                        self.statusMessage = "Error checking VPN status: \(error.localizedDescription)"
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                switch vpnManager.connection.status {
                case .connected:
                    self.isConnected = true
                    self.isLoading = false
                    self.statusMessage = ""
                    

                    
                case .connecting:
                    self.isLoading = true
                    self.statusMessage = ""
                case .disconnecting:
                    self.isLoading = true
                    self.statusMessage = ""
                case .disconnected, .invalid:
                    self.isConnected = false
                    self.isLoading = false
                    self.statusMessage = ""
                @unknown default:
                    self.isConnected = false
                    self.isLoading = false
                    self.statusMessage = ""
                }
            }
            
            // Set up observation of status changes
            NotificationCenter.default.addObserver(
                forName: .NEVPNStatusDidChange,
                object: vpnManager.connection,
                queue: OperationQueue.main) { _ in
                    DispatchQueue.main.async {
                        switch vpnManager.connection.status {
                        case .connected:
                            self.isConnected = true
                            self.isLoading = false
                            self.statusMessage = ""
                            

                            

                            
                        case .connecting:
                            self.isLoading = true
                            self.statusMessage = ""
                        case .disconnecting:
                            self.isLoading = true
                            self.statusMessage = ""
                        case .disconnected, .invalid:
                            self.isConnected = false
                            self.isLoading = false
                            self.statusMessage = ""
                        @unknown default:
                            self.isConnected = false
                            self.isLoading = false
                            self.statusMessage = ""
                        }
                    }
            }
        }
    }
    
    private func setupAndConnectVPN() {
        // Check subscription status before connecting
        if !revenueCatManager.isSubscribed {
            // Show paywall if not subscribed
            showingPaywall = true
            return
        }

        connectVPNAfterConsent()
    }

    private func connectVPNAfterConsent() {
        // Check subscription status before connecting
        if !revenueCatManager.isSubscribed {
            showingPaywall = true
            return
        }

        // Check if running in simulator
        #if targetEnvironment(simulator)
        statusMessage = "VPN functionality not available in iOS Simulator. Please test on a real device."
        return
        #endif

        // Ensure a server is selected
        guard let server = selectedServer else {
            statusMessage = "Please select a server first"
            return
        }

        // Ensure server has credentials
        guard let username = server.openvpnUsername,
              let password = server.openvpnPassword else {
            statusMessage = "Server credentials not available"
            return
        }
        
        isLoading = true
        statusMessage = "Connecting to \(server.name)..."
        
        let serverAddress = server.serverAddress
        
        // Get shared secret from keychain (still needed for IPSec)
        guard let sharedSecretData = loadFromKeychain(key: kKeychainVPNSharedSecretKey),
              let sharedSecret = String(data: sharedSecretData, encoding: .utf8) else {
            
            DispatchQueue.main.async {
                self.statusMessage = "Error: Missing shared secret"
                self.isLoading = false
                self.saveDefaultCredentials()
            }
            return
        }
        

        
        let vpnManager = NEVPNManager.shared()
        vpnManager.loadFromPreferences { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Error loading VPN preferences: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            // Setup IPSec configuration
            let ipSecConfig = NEVPNProtocolIPSec()
            ipSecConfig.serverAddress = serverAddress
            ipSecConfig.username = username
            
            // Convert password to data and save as password reference
            if let passwordRef = self.createPasswordReference(username: username, password: password) {
                ipSecConfig.passwordReference = passwordRef
            } else {
                DispatchQueue.main.async {
                    self.statusMessage = "Error creating password reference"
                    self.isLoading = false
                }
                return
            }
            
            ipSecConfig.authenticationMethod = .sharedSecret
            if let sharedSecretRef = self.createSharedSecretReference(secret: sharedSecret) {
                ipSecConfig.sharedSecretReference = sharedSecretRef
            } else {
                DispatchQueue.main.async {
                    self.statusMessage = "Error creating shared secret reference"
                    self.isLoading = false
                }
                return
            }
            
            // Match the config in the mobileconfig file
            ipSecConfig.localIdentifier = ""
            ipSecConfig.remoteIdentifier = serverAddress
            ipSecConfig.useExtendedAuthentication = true  // This is equivalent to XAuthEnabled in mobileconfig
            
            vpnManager.protocolConfiguration = ipSecConfig
            vpnManager.isEnabled = true
            vpnManager.localizedDescription = "FoxyWall"
            
            // Save the configuration
            vpnManager.saveToPreferences { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.statusMessage = "Error saving VPN preferences: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                // Try to connect
                do {
                    try vpnManager.connection.startVPNTunnel()

                    

                    
                } catch let error {
                    DispatchQueue.main.async {
                        self.statusMessage = "Failed to start VPN: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func createPasswordReference(username: String, password: String) -> Data? {
        let passwordData = password.data(using: .utf8)!
        
        // Create a keychain query
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "VPNService",
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData,
            kSecReturnPersistentRef as String: true
        ]
        
        // Remove any existing keychain item
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "VPNService",
            kSecAttrAccount as String: username
        ] as CFDictionary)
        
        // Add the new keychain item
        var result: CFTypeRef?
        let status = SecItemAdd(keychainQuery as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {

            return nil
        }
    }
    
    private func createSharedSecretReference(secret: String) -> Data? {
        let secretData = secret.data(using: .utf8)!
        
        // Create a keychain query
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "VPNSharedSecret",
            kSecAttrAccount as String: "SharedSecret",
            kSecValueData as String: secretData,
            kSecReturnPersistentRef as String: true
        ]
        
        // Remove any existing keychain item
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "VPNSharedSecret",
            kSecAttrAccount as String: "SharedSecret"
        ] as CFDictionary)
        
        // Add the new keychain item
        var result: CFTypeRef?
        let status = SecItemAdd(keychainQuery as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {

            return nil
        }
    }
    
    private func disconnectVPN() {
        // Check if running in simulator
        #if targetEnvironment(simulator)
        statusMessage = "VPN functionality not available in iOS Simulator."
        return
        #endif
        
        isLoading = true
statusMessage = ""
        
        let vpnManager = NEVPNManager.shared()
        vpnManager.connection.stopVPNTunnel()
        // Status will be updated through the notification observer
    }
    
    // MARK: - Keychain Helper Functions
    
    private func saveToKeychain(key: String, data: Data) -> Bool {
        // First delete any existing item
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as CFDictionary)
        
        // Now add the new item
        let status = SecItemAdd([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ] as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    private func loadFromKeychain(key: String) -> Data? {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {

            return nil
        }
    }
    

    
    private func fetchVPNServers() {
        isLoadingServers = true
        
        SupabaseConfig.shared.fetchVPNServers { [self] result in
            DispatchQueue.main.async {
                self.isLoadingServers = false
                
                switch result {
                case .success(let servers):
                    // Sort servers: Free servers always on top!
                    var sortedServers = servers.sorted { server1, server2 in
                        // If one is free and other is premium, free comes first
                        if !server1.isPremium && server2.isPremium {
                            return true
                        }
                        if server1.isPremium && !server2.isPremium {
                            return false
                        }
                        // Otherwise sort by name
                        return server1.name < server2.name
                    }
                    
                    self.vpnServers = sortedServers
                    
                    // Set Stockholm (free server) as default if none selected
                    // The user specifically wants Sweden preselected
                    if self.selectedServer == nil {
                        // Priority 1: Stockholm/Sweden Free Server
                        if let stockholmServer = sortedServers.first(where: { 
                            ($0.id == "stockholm1" || $0.name.lowercased().contains("sweden") || $0.name.lowercased().contains("stockholm")) && !$0.isPremium 
                        }) {
                            self.selectedServer = stockholmServer
                        } 
                        // Priority 2: Any Free Server (since they are sorted on top, just take first)
                        else if let firstFreeServer = sortedServers.first(where: { !$0.isPremium }) {
                            self.selectedServer = firstFreeServer
                        } 
                        // Priority 3: First available
                        else if let firstServer = sortedServers.first {
                            self.selectedServer = firstServer
                        }
                    }
                    
                    self.statusMessage = "Loaded \(servers.count) VPN servers"
                    
                case .failure(let error):
                    self.statusMessage = "Failed to load servers: \(error.localizedDescription)"
                    // Fallback to default server if Supabase fails
                }
            }
        }
    }
    

}



// MARK: - Settings View
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEULA = false
    
    public init() {}
    
    private var backgroundColor: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    public var body: some View {
        #if os(iOS)
        NavigationView {
            mainSettingsContent
        }
        #else
        // macOS: Use full-screen layout without NavigationView
        VStack {
            // Custom header for macOS
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(backgroundColor)
            
            mainSettingsContent
                .padding()
        }
        .frame(minWidth: 600, idealWidth: 700, minHeight: 500, idealHeight: 600)
        #endif
    }
    
    private var mainSettingsContent: some View {
        List {

            
            Section("Device Info") {
                HStack {
                    Text("Local IP Address")
                    Spacer()
                    Text(getLocalIPAddress())
                        .foregroundColor(.gray)
                }
            }
            
            Section("Privacy") {
                Link("Privacy Policy", destination: URL(string: "https://theholylabs.com/privacy")!)
                    .foregroundColor(.blue)
            }
            
            Section("Legal") {
                Button("End User License Agreement") {
                    showingEULA = true
                }
                .foregroundColor(.primary)
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("2.10")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("App Name")
                    Spacer()
                    Text("FoxyWall")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    dismiss()
                }
            }
            #endif
        }
        .sheet(isPresented: $showingEULA) {
            EULAView()
        }
    }
    
    private func getLocalIPAddress() -> String {
        var address: String = "Unknown"
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return address
        }
        defer { freeifaddrs(ifaddr) }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: (interface?.ifa_name)!)
                
                #if os(iOS)
                // iOS network interfaces
                if name == "en0" || name == "en1" || name == "en2" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr,
                               socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                               &hostname,
                               socklen_t(hostname.count),
                               nil,
                               0,
                               NI_NUMERICHOST)
                    address = String(cString: hostname)
                    break
                }
                #else
                // macOS network interfaces
                if name == "en0" || name == "en1" || name == "en2" || name == "en3" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr,
                               socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                               &hostname,
                               socklen_t(hostname.count),
                               nil,
                               0,
                               NI_NUMERICHOST)
                    address = String(cString: hostname)
                    break
                }
                #endif
            }
        }
        
        return address
    }
}

// MARK: - EULA View
struct EULAView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(eulaText)
                        .font(.system(size: 14))
                        .padding()
                }
            }
            .navigationTitle("End User License Agreement")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private let eulaText = """
LICENSED APPLICATION END USER LICENSE AGREEMENT

Apps made available through the App Store are licensed, not sold, to you. Your license to each App is subject to your prior acceptance of either this Licensed Application End User License Agreement ("Standard EULA"), or a custom end user license agreement between you and the Application Provider ("Custom EULA"), if one is provided. Your license to any Apple App under this Standard EULA or Custom EULA is granted by Apple, and your license to any Third Party App under this Standard EULA or Custom EULA is granted by the Application Provider of that Third Party App. Any App that is subject to this Standard EULA is referred to herein as the "Licensed Application." The Application Provider or Apple as applicable ("Licensor") reserves all rights in and to the Licensed Application not expressly granted to you under this Standard EULA.

a. Scope of License: Licensor grants to you a nontransferable license to use the Licensed Application on any Apple-branded products that you own or control and as permitted by the Usage Rules. The terms of this Standard EULA will govern any content, materials, or services accessible from or purchased within the Licensed Application as well as upgrades provided by Licensor that replace or supplement the original Licensed Application, unless such upgrade is accompanied by a Custom EULA. Except as provided in the Usage Rules, you may not distribute or make the Licensed Application available over a network where it could be used by multiple devices at the same time. You may not transfer, redistribute or sublicense the Licensed Application and, if you sell your Apple Device to a third party, you must remove the Licensed Application from the Apple Device before doing so. You may not copy (except as permitted by this license and the Usage Rules), reverse-engineer, disassemble, attempt to derive the source code of, modify, or create derivative works of the Licensed Application, any updates, or any part thereof (except as and only to the extent that any foregoing restriction is prohibited by applicable law or to the extent as may be permitted by the licensing terms governing use of any open-sourced components included with the Licensed Application).

b. Consent to Use of Data: You agree that Licensor may collect and use technical data and related information—including but not limited to technical information about your device, system and application software, and peripherals—that is gathered periodically to facilitate the provision of software updates, product support, and other services to you (if any) related to the Licensed Application. Licensor may use this information, as long as it is in a form that does not personally identify you, to improve its products or to provide services or technologies to you.

c. Termination. This Standard EULA is effective until terminated by you or Licensor. Your rights under this Standard EULA will terminate automatically if you fail to comply with any of its terms.

d. External Services. The Licensed Application may enable access to Licensor's and/or third-party services and websites (collectively and individually, "External Services"). You agree to use the External Services at your sole risk. Licensor is not responsible for examining or evaluating the content or accuracy of any third-party External Services, and shall not be liable for any such third-party External Services. Data displayed by any Licensed Application or External Service, including but not limited to financial, medical and location information, is for general informational purposes only and is not guaranteed by Licensor or its agents. You will not use the External Services in any manner that is inconsistent with the terms of this Standard EULA or that infringes the intellectual property rights of Licensor or any third party. You agree not to use the External Services to harass, abuse, stalk, threaten or defame any person or entity, and that Licensor is not responsible for any such use. External Services may not be available in all languages or in your Home Country, and may not be appropriate or available for use in any particular location. To the extent you choose to use such External Services, you are solely responsible for compliance with any applicable laws. Licensor reserves the right to change, suspend, remove, disable or impose access restrictions or limits on any External Services at any time without notice or liability to you.

e. NO WARRANTY: YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT USE OF THE LICENSED APPLICATION IS AT YOUR SOLE RISK. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED APPLICATION AND ANY SERVICES PERFORMED OR PROVIDED BY THE LICENSED APPLICATION ARE PROVIDED "AS IS" AND "AS AVAILABLE," WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND, AND LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS WITH RESPECT TO THE LICENSED APPLICATION AND ANY SERVICES, EITHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES AND/OR CONDITIONS OF MERCHANTABILITY, OF SATISFACTORY QUALITY, OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY, OF QUIET ENJOYMENT, AND OF NONINFRINGEMENT OF THIRD-PARTY RIGHTS. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY LICENSOR OR ITS AUTHORIZED REPRESENTATIVE SHALL CREATE A WARRANTY. SHOULD THE LICENSED APPLICATION OR SERVICES PROVE DEFECTIVE, YOU ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES OR LIMITATIONS ON APPLICABLE STATUTORY RIGHTS OF A CONSUMER, SO THE ABOVE EXCLUSION AND LIMITATIONS MAY NOT APPLY TO YOU.

f. Limitation of Liability. TO THE EXTENT NOT PROHIBITED BY LAW, IN NO EVENT SHALL LICENSOR BE LIABLE FOR PERSONAL INJURY OR ANY INCIDENTAL, SPECIAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, LOSS OF DATA, BUSINESS INTERRUPTION, OR ANY OTHER COMMERCIAL DAMAGES OR LOSSES, ARISING OUT OF OR RELATED TO YOUR USE OF OR INABILITY TO USE THE LICENSED APPLICATION, HOWEVER CAUSED, REGARDLESS OF THE THEORY OF LIABILITY (CONTRACT, TORT, OR OTHERWISE) AND EVEN IF LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OF LIABILITY FOR PERSONAL INJURY, OR OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THIS LIMITATION MAY NOT APPLY TO YOU. In no event shall Licensor's total liability to you for all damages (other than as may be required by applicable law in cases involving personal injury) exceed the amount of fifty dollars ($50.00). The foregoing limitations will apply even if the above stated remedy fails of its essential purpose.

g. You may not use or otherwise export or re-export the Licensed Application except as authorized by United States law and the laws of the jurisdiction in which the Licensed Application was obtained. In particular, but without limitation, the Licensed Application may not be exported or re-exported (a) into any U.S.-embargoed countries or (b) to anyone on the U.S. Treasury Department's Specially Designated Nationals List or the U.S. Department of Commerce Denied Persons List or Entity List. By using the Licensed Application, you represent and warrant that you are not located in any such country or on any such list. You also agree that you will not use these products for any purposes prohibited by United States law, including, without limitation, the development, design, manufacture, or production of nuclear, missile, or chemical or biological weapons.

h. The Licensed Application and related documentation are "Commercial Items", as that term is defined at 48 C.F.R. §2.101, consisting of "Commercial Computer Software" and "Commercial Computer Software Documentation", as such terms are used in 48 C.F.R. §12.212 or 48 C.F.R. §227.7202, as applicable. Consistent with 48 C.F.R. §12.212 or 48 C.F.R. §227.7202-1 through 227.7202-4, as applicable, the Commercial Computer Software and Commercial Computer Software Documentation are being licensed to U.S. Government end users (a) only as Commercial Items and (b) with only those rights as are granted to all other end users pursuant to the terms and conditions herein. Unpublished-rights reserved under the copyright laws of the United States.

i. Except to the extent expressly provided in the following paragraph, this Agreement and the relationship between you and Apple shall be governed by the laws of the State of California, excluding its conflicts of law provisions. You and Apple agree to submit to the personal and exclusive jurisdiction of the courts located within the county of Santa Clara, California, to resolve any dispute or claim arising from this Agreement. If (a) you are not a U.S. citizen; (b) you do not reside in the U.S.; (c) you are not accessing the Service from the U.S.; and (d) you are a citizen of one of the countries identified below, you hereby agree that any dispute or claim arising from this Agreement shall be governed by the applicable law set forth below, without regard to any conflict of law provisions, and you hereby irrevocably submit to the non-exclusive jurisdiction of the courts located in the state, province or country identified below whose law governs:

If you are a citizen of any European Union country or Switzerland, Norway or Iceland, the governing law and forum shall be the laws and courts of your usual place of residence.

Specifically excluded from application to this Agreement is that law known as the United Nations Convention on the International Sale of Goods.

Source: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
"""
}


// MARK: - Speedtest-style Gauge View
struct SpeedtestGaugeView: View {
    let currentSpeed: Double
    let isRunning: Bool
    var hasResult: Bool = false
    let phase: SpeedTestService.TestPhase
    var speedText: String? = nil

    private static let scaleMarks: [(value: Double, label: String)] = [
        (0, "0"), (1, "1"), (5, "5"), (10, "10"),
        (20, "20"), (30, "30"), (50, "50"), (75, "75"), (100, "100")
    ]

    static func logFraction(_ speed: Double) -> Double {
        guard speed > 0 else { return 0 }
        let clamped = min(speed, 100)
        return log10(1 + clamped) / log10(101)
    }

    private var needleFraction: Double {
        Self.logFraction(currentSpeed)
    }

    private static let startAngle: Double = 135
    private static let endAngle: Double = 405
    private static let sweep: Double = endAngle - startAngle

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let arcRadius = size / 2 - 36
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                gaugeTrack(arcRadius: arcRadius, center: center)
                gaugeFill(arcRadius: arcRadius, center: center)
                scaleLabels(arcRadius: arcRadius, center: center)
                scaleTicks(arcRadius: arcRadius, center: center)
                centerContent(center: center)
            }
        }
    }

    private func gaugeTrack(arcRadius: CGFloat, center: CGPoint) -> some View {
        SpeedtestArcShape(startAngle: Self.startAngle, endAngle: Self.endAngle)
            .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 22, lineCap: .round))
            .frame(width: arcRadius * 2, height: arcRadius * 2)
            .position(center)
    }

    private func gaugeFill(arcRadius: CGFloat, center: CGPoint) -> some View {
        SpeedtestArcShape(startAngle: Self.startAngle, endAngle: Self.endAngle)
            .trim(from: 0, to: CGFloat(needleFraction))
            .stroke(
                AngularGradient(
                    colors: [.cyan, .cyan, .green, .green],
                    center: .center,
                    startAngle: .degrees(Self.startAngle),
                    endAngle: .degrees(Self.endAngle)
                ),
                style: StrokeStyle(lineWidth: 22, lineCap: .round)
            )
            .frame(width: arcRadius * 2, height: arcRadius * 2)
            .position(center)
            .animation(.easeOut(duration: 0.4), value: needleFraction)
    }

    private func scaleLabels(arcRadius: CGFloat, center: CGPoint) -> some View {
        ForEach(Self.scaleMarks, id: \.label) { mark in
            scaleLabel(mark: mark, arcRadius: arcRadius, center: center)
        }
    }

    private func scaleLabel(mark: (value: Double, label: String), arcRadius: CGFloat, center: CGPoint) -> some View {
        let frac = Self.logFraction(mark.value)
        let angle = Self.startAngle + frac * Self.sweep
        let labelRadius = arcRadius + 28
        let rad = angle * .pi / 180
        let x = center.x + labelRadius * cos(rad)
        let y = center.y + labelRadius * sin(rad)
        return Text(mark.label)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.primary.opacity(0.7))
            .position(x: x, y: y)
    }

    private func scaleTicks(arcRadius: CGFloat, center: CGPoint) -> some View {
        ForEach(Self.scaleMarks, id: \.label) { mark in
            scaleTick(mark: mark, arcRadius: arcRadius, center: center)
        }
    }

    private func scaleTick(mark: (value: Double, label: String), arcRadius: CGFloat, center: CGPoint) -> some View {
        let frac = Self.logFraction(mark.value)
        let angle = Self.startAngle + frac * Self.sweep
        let rad = angle * .pi / 180
        let outerR = arcRadius - 13
        let innerR = arcRadius - 32
        return Path { p in
            p.move(to: CGPoint(
                x: center.x + innerR * cos(rad),
                y: center.y + innerR * sin(rad)
            ))
            p.addLine(to: CGPoint(
                x: center.x + outerR * cos(rad),
                y: center.y + outerR * sin(rad)
            ))
        }
        .stroke(Color.primary.opacity(0.3), lineWidth: 2.5)
    }

    @ViewBuilder
    private func centerContent(center: CGPoint) -> some View {
        if !isRunning && !hasResult {
            Text("GO")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.cyan)
                .position(center)
        } else {
            VStack(spacing: 2) {
                Text(speedText ?? "—")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Mbps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if isRunning {
                    Text(phase.description)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .position(center)
        }
    }
}

struct SpeedtestArcShape: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width, rect.height) / 2
        let c = CGPoint(x: rect.midX, y: rect.midY)
        p.addArc(center: c, radius: r, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
        return p
    }
}

struct TracerouteMapView: View {
    let hops: [TracerouteHop]

    /// Classic map: default world region when no route is shown
    private static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25, longitude: 15),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )

    var body: some View {
        Map(initialPosition: .region(TracerouteMapView.defaultRegion)) {
            ForEach(hops) { hop in
                if let coord = hop.coordinate {
                    Annotation(hop.host, coordinate: coord) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }

            if hops.count > 1 {
                MapPolyline(coordinates: hops.compactMap { $0.coordinate })
                    .stroke(Color.blue, lineWidth: 2)
            }
        }
        .mapStyle(.standard)
    }
}

// MARK: - Traceroute Sheet View
struct TracerouteSheetView: View {
    @ObservedObject var tracerouteService: TracerouteService
    @Binding var destination: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Enter IP or domain", text: $destination)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .submitLabel(.go)
                        .onSubmit {
                            if !tracerouteService.isRunning && !destination.isEmpty {
                                tracerouteService.traceroute(to: destination)
                            }
                        }

                    if tracerouteService.isRunning {
                        ProgressView()
                    } else if !destination.isEmpty {
                        Button(action: {
                            tracerouteService.traceroute(to: destination)
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Hops list
                if tracerouteService.hops.isEmpty && !tracerouteService.isRunning {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Enter an IP or domain to trace")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(tracerouteService.hops.enumerated()), id: \.element.id) { index, hop in
                                HStack(spacing: 12) {
                                    Text("\(hop.hopNumber)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(hop.status == .timeout ? Color.orange : Color.blue)
                                        .clipShape(Circle())

                                    if let flag = hop.flagEmoji {
                                        Text(flag)
                                            .font(.title3)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(hop.host)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        if let ip = hop.ip {
                                            Text(ip)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if let latency = hop.latencyMs {
                                        Text(String(format: "%.0f ms", latency))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(latency < 50 ? .green : (latency < 100 ? .orange : .red))
                                    } else if hop.status == .timeout {
                                        Text("* * *")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)

                                if index < tracerouteService.hops.count - 1 {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Traceroute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
