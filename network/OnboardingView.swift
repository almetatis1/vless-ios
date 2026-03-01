import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @AppStorage("appTheme") private var appTheme: String = "dark"
    @State private var currentPage = 0

    private let totalPages = 4

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    onboardingPage(
                        icon: "pawprint.fill",
                        iconColor: .orange,
                        title: L10n.onboardingWelcomeTitle,
                        subtitle: L10n.onboardingWelcomeSubtitle
                    )
                    .tag(0)

                    onboardingPage(
                        icon: "shield.fill",
                        iconColor: .green,
                        title: L10n.onboardingVpnTitle,
                        subtitle: L10n.onboardingVpnSubtitle
                    )
                    .tag(1)

                    onboardingPage(
                        icon: "speedometer",
                        iconColor: .cyan,
                        title: L10n.onboardingSpeedTitle,
                        subtitle: L10n.onboardingSpeedSubtitle
                    )
                    .tag(2)

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

                        Text(L10n.onboardingReadyTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(L10n.onboardingReadySubtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()

                        Button(action: {
                            hasSeenOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        }) {
                            Text(L10n.onboardingContinue)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 40)

                        Text(L10n.onboardingLegal)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                    }
                    .tag(3)
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
