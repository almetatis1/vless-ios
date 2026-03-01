// MARK: - Supabase Server Selector View

import SwiftUI
struct SupabaseServerSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedServer: VPNServer?
    let vpnServers: [VPNServer]
    let isLoadingServers: Bool
    let onRefresh: () -> Void
    
    private var backgroundColor: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(L10n.selectVpnServer)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(L10n.done) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(backgroundColor)
            
            // Content
            if isLoadingServers {
                ProgressView(L10n.loadingServers)
                    .padding()
            } else if vpnServers.isEmpty {
                VStack(spacing: 12) {
                    Text(L10n.noServersAvailable)
                        .font(.headline)
                    Button(L10n.refresh) {
                        onRefresh()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vpnServers) { server in
                            SupabaseServerRow(
                                server: server,
                                isSelected: selectedServer?.id == server.id
                            ) {
                                selectedServer = server
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    onRefresh()
                }
            }
            
            Spacer()
        }
        .background(backgroundColor)
    }
}

// MARK: - Supabase Server Row Component
struct PingBarsView: View {
    let pingMs: Double?

    private var filledBars: Int {
        guard let ms = pingMs else { return 0 }
        if ms < 60  { return 4 }
        if ms < 120 { return 3 }
        if ms < 200 { return 2 }
        return 1
    }

    private var barColor: Color {
        guard let ms = pingMs else { return .gray.opacity(0.3) }
        if ms < 60  { return .green }
        if ms < 120 { return Color(red: 0.6, green: 0.85, blue: 0.2) }
        if ms < 200 { return .orange }
        return .red
    }

    var body: some View {
        if pingMs == nil {
            ProgressView()
                .scaleEffect(0.7)
                .frame(width: 26, height: 22)
        } else {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < filledBars ? barColor : Color.gray.opacity(0.2))
                        .frame(width: 5, height: CGFloat(6 + i * 4))
                }
            }
        }
    }
}

struct SupabaseServerRow: View {
    let server: VPNServer
    let isSelected: Bool
    var pingMs: Double? = nil
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Flag emoji
                Text(server.flag)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(server.localizedCityName(preferredLocale: LanguageManager.shared.currentLanguageCode))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        if server.hasVlessConfig {
                            Text(L10n.vless)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.cyan.opacity(0.2))
                                .cornerRadius(4)
                        }
                        if let ms = pingMs {
                            Text("\(Int(round(ms))) ms")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    PingBarsView(pingMs: pingMs)
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
