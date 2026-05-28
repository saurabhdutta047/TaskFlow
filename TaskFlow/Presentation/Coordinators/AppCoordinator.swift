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
        let taskListView = TaskListView(viewModel: viewModel, coordinator: self)
        let profileViewModel = dependencyContainer.makeUserProfileViewModel()
        let profileView = UserProfileView(viewModel: profileViewModel)
        let mainView = MainTabView(
            taskListView: AnyView(taskListView),
            profileView: AnyView(profileView)
        )
        return AnyView(mainView)
    }
    
    func showTaskDetail(for task: TaskItem?) -> AnyView {
        let viewModel = dependencyContainer.makeTaskDetailViewModel(task: task)
        let view = TaskDetailView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }

    func showTaskDetails(for task: TaskItem) -> AnyView {
        let viewModel = dependencyContainer.makeTaskDetailsViewModel(task: task)
        let view = TaskDetailsView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }
}
