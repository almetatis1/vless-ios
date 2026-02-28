import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @AppStorage("appTheme") private var appTheme: String = "dark"
    @State private var currentPage = 0

    private let totalPages = 5

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    onboardingPage(
                        icon: "pawprint.fill",
                        iconColor: .orange,
                        title: "Welcome to FoxyWall",
                        subtitle: "Your privacy companion.\nSecure your connection with one tap."
                    )
                    .tag(0)

                    onboardingPage(
                        icon: "shield.fill",
                        iconColor: .green,
                        title: "VPN Protection",
                        subtitle: "Connect to servers worldwide and encrypt all your internet traffic instantly."
                    )
                    .tag(1)

                    onboardingPage(
                        icon: "speedometer",
                        iconColor: .cyan,
                        title: "Speed Test",
                        subtitle: "Measure your download, upload, ping, and jitter with a single tap."
                    )
                    .tag(2)

                    onboardingPage(
                        icon: "point.topleft.down.to.point.bottomright.curvepath.fill",
                        iconColor: .purple,
                        title: "Network Tools",
                        subtitle: "Trace the route your data takes across the internet and diagnose connection issues."
                    )
                    .tag(3)

                    VStack(spacing: 32) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 140, height: 140)
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.green)
                        }

                        Text("Ready to Go")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("No logs. No tracking.\nYour data stays yours.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()

                        Button(action: {
                            hasSeenOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 40)

                        Text("By continuing, you accept our Privacy Policy and Terms of Use.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                    }
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .preferredColorScheme(appTheme == "light" ? .light : .dark)
    }

    private func onboardingPage(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}
