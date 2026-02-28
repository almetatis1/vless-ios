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
                Text("Select VPN Server")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(backgroundColor)
            
            // Content
            if isLoadingServers {
                ProgressView("Loading servers...")
                    .padding()
            } else if vpnServers.isEmpty {
                VStack(spacing: 12) {
                    Text("No servers available")
                        .font(.headline)
                    Button("Refresh") {
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
struct SupabaseServerRow: View {
    let server: VPNServer
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Flag emoji
                Text(server.flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(server.name) - \(server.city)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        // Status indicator
                        Circle()
                            .fill(server.isAvailable ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(server.status.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
