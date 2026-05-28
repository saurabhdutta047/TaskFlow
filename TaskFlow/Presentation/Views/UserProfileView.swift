import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    init(viewModel: UserProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                productivityStats
                accountSettings
                appPreferences
                signOutButton
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            Task { await viewModel.loadStats() }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    )

                Circle()
                    .fill(primaryBlue)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
            }

            Text("Alex Rivera")
                .font(.title2)
                .fontWeight(.bold)

            Text("Product Designer")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Productivity Stats

    private var productivityStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRODUCTIVITY STATS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.2)

            VStack(spacing: 12) {
                statsCard(
                    icon: "checkmark.circle.fill",
                    iconColor: primaryBlue,
                    value: "\(viewModel.completedTasks)",
                    label: "Tasks Completed"
                )

                HStack(spacing: 12) {
                    statsCard(
                        icon: "bolt.fill",
                        iconColor: .green,
                        value: "\(viewModel.completedTasks)",
                        label: "Current Streak"
                    )

                    statsCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: primaryBlue,
                        value: "\(viewModel.efficiencyScore)%",
                        label: "Efficiency Score"
                    )
                }
            }
        }
    }

    private func statsCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 28, weight: .bold))

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Account Settings

    private var accountSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACCOUNT SETTINGS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.2)

            VStack(spacing: 0) {
                settingsRow(icon: "person.crop.circle", title: "Personal Info")
                Divider().padding(.leading, 52)
                settingsRow(icon: "bell", title: "Notifications")
                Divider().padding(.leading, 52)
                settingsRow(icon: "shield.checkered", title: "Security")
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - App Preferences

    private var appPreferences: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APP PREFERENCES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.2)

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: "moon.fill")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 24)

                    Text("Dark Mode")
                        .font(.body)

                    Spacer()

                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                        .tint(primaryBlue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider().padding(.leading, 52)

                HStack(spacing: 14) {
                    Image(systemName: "globe")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 24)

                    Text("Language")
                        .font(.body)

                    Spacer()

                    Text("English")
                        .font(.body)
                        .foregroundColor(.gray)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(action: {}) {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
        }
    }
}
