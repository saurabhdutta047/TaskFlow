import SwiftUI

@main
struct TaskFlowApp: App {
    private let dependencyContainer: AppDependencyContainer
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
