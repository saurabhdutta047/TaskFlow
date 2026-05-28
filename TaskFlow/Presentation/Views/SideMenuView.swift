import SwiftUI

/// Slide-out sidebar menu displayed over the task list.
///
/// Contains a mock user profile header, navigation items grouped into
/// MAIN (Tasks, Calendar, Inbox) and ANALYSIS (Productivity Insights,
/// Categories) sections, plus a footer with Settings, Help & Support,
/// and Log Out.
struct SideMenuView: View {
    /// Controls the open/close state of the menu. Bound to the parent view.
    @Binding var isOpen: Bool

    /// The current number of tasks, shown as a badge on the Tasks menu item.
    let taskCount: Int

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileHeader
            Divider().padding(.horizontal, 16)
            mainSection
            analysisSection

            Spacer()

            Divider().padding(.horizontal, 16)
            bottomSection
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                )
                .overlay(
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .offset(x: 18, y: 18)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Alex Rivers")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("alex.rivers@taskfl...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
    }

    // MARK: - Main Section

    private var mainSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MAIN")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.0)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            menuRow(icon: "checkmark.circle.fill", title: "Tasks", isSelected: true, badge: taskCount > 0 ? "\(taskCount)" : nil) {
                isOpen = false
            }

            menuRow(icon: "calendar", title: "Calendar") {
                isOpen = false
            }

            menuRow(icon: "envelope.fill", title: "Inbox", hasNotification: true) {
                isOpen = false
            }
        }
    }

    // MARK: - Analysis Section

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ANALYSIS")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.0)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

            menuRow(icon: "chart.bar.fill", title: "Productivity Insights") {
                isOpen = false
            }

            menuRow(icon: "square.grid.2x2.fill", title: "Categories") {
                isOpen = false
            }
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            menuRow(icon: "gearshape.fill", title: "Settings") {
                isOpen = false
            }

            menuRow(icon: "questionmark.circle", title: "Help & Support") {
                isOpen = false
            }

            Button(action: { isOpen = false }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body)
                        .foregroundColor(.red)
                        .frame(width: 24)

                    Text("Log Out")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Menu Row

    private func menuRow(
        icon: String,
        title: String,
        isSelected: Bool = false,
        badge: String? = nil,
        hasNotification: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(primaryBlue)
                        .frame(width: 3, height: 24)
                } else {
                    Spacer().frame(width: 3)
                }

                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(isSelected ? primaryBlue : .primary)
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? primaryBlue : .primary)

                Spacer()

                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(primaryBlue)
                        .cornerRadius(10)
                }

                if hasNotification {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? primaryBlue.opacity(0.08) : Color.clear
            )
        }
    }
}
