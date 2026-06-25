import SwiftUI
import SwiftData

/// The application entry point.
///
/// Bootstraps the SwiftData container, dependency injection container, and coordinator,
/// then presents the root view returned by `AppCoordinator.start()`.
@main
struct TaskFlowApp: App {
    /// The SwiftData model container that manages the database for task persistence.
    let modelContainer: ModelContainer

    /// The DI container that owns all shared services and use cases.
    private let dependencyContainer: AppDependencyContainer

    /// The root coordinator that manages screen creation and navigation.
    private let coordinator: AppCoordinator

    init() {
        do {
            // Configure SwiftData with the TaskItem model
            let schema = Schema([TaskItem.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Initialize dependency injection with the SwiftData context
            dependencyContainer = AppDependencyContainer(modelContext: modelContainer.mainContext)
            coordinator = dependencyContainer.makeAppCoordinator()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
        .modelContainer(modelContainer)
    }
}
