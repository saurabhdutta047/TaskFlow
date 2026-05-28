import SwiftUI

struct MainTabView: View {
    let taskListView: AnyView
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

struct PlaceholderTabView: View {
    let title: String
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
