import SwiftUI

/// The application entry point.
///
/// Bootstraps the dependency injection container and coordinator,
/// then presents the root view returned by `AppCoordinator.start()`.
@main
struct TaskFlowApp: App {
    /// The DI container that owns all shared services and use cases.
    private let dependencyContainer: AppDependencyContainer

    /// The root coordinator that manages screen creation and navigation.
    private let coordinator: AppCoordinator
    
    init() {
        dependencyContainer = AppDependencyContainer()
        coordinator = dependencyContainer.makeAppCoordinator()
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
