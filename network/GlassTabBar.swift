import SwiftUI

// MARK: - Tab Item Enum
enum AppTab: String, CaseIterable {
    case vpn = "VPN"
    case scanner = "Speed"
    case tools = "Tools"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .vpn:
            return "globe"
        case .scanner:
            return "speedometer"
        case .tools:
            return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

// MARK: - Network Tool Button
struct NetworkToolButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glass Tab Bar
struct GlassTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            // Top separator line - iOS style
            Divider()
            
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabBarItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        namespace: animation
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "tab", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
