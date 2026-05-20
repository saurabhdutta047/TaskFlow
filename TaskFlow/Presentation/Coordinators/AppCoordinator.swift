import SwiftUI

@MainActor
protocol Coordinator: AnyObject {
    func start() -> AnyView
}

@MainActor
final class AppCoordinator: Coordinator {
    private let dependencyContainer: AppDependencyContainer
    
    init(dependencyContainer: AppDependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func start() -> AnyView {
        let viewModel = dependencyContainer.makeTaskListViewModel()
        let view = TaskListView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }
    
    func showTaskDetail(for task: TaskItem?) -> AnyView {
        let viewModel = dependencyContainer.makeTaskDetailViewModel(task: task)
        let view = TaskDetailView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }
}
