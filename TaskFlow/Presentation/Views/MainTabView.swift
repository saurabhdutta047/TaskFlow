import SwiftUI

/// Root container view that hosts the bottom tab bar navigation.
///
/// Presents four tabs: Tasks (the main list), Calendar and Inbox (placeholders),
/// and Settings (the user profile screen). Child views are injected as
/// type-erased `AnyView` instances by `AppCoordinator`.
struct MainTabView: View {
    /// The fully-configured task list view created by the coordinator.
    let taskListView: AnyView

    /// The fully-configured user profile view created by the coordinator.
    let profileView: AnyView

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    var body: some View {
        TabView {
            taskListView
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Tasks")
                }

            PlaceholderTabView(title: "Calendar", icon: "calendar")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }

            PlaceholderTabView(title: "Inbox", icon: "tray.fill")
                .tabItem {
                    Image(systemName: "tray.fill")
                    Text("Inbox")
                }

            profileView
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .tint(primaryBlue)
    }
}

/// A generic placeholder view displayed for tabs that are not yet implemented.
///
/// Shows a centered icon, title, and "Coming Soon" label.
struct PlaceholderTabView: View {
    /// The tab's display name.
    let title: String

    /// The SF Symbol name for the tab's icon.
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
