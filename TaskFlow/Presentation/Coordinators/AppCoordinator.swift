import SwiftUI

/// Base protocol for coordinator objects that manage navigation flow.
///
/// Coordinators own the creation and presentation of screens, keeping
/// navigation logic out of views and view models.
@MainActor
protocol Coordinator: AnyObject {
    /// Creates and returns the root view of the coordinator's flow.
    func start() -> AnyView
}

/// The app's single coordinator responsible for all navigation.
///
/// `AppCoordinator` uses `AppDependencyContainer` to build fully-wired
/// view models and views. It provides factory methods for each screen
/// so that views never instantiate their own dependencies.
@MainActor
final class AppCoordinator: Coordinator {
    private let dependencyContainer: AppDependencyContainer
    
    /// - Parameter dependencyContainer: The DI container that supplies all dependencies.
    init(dependencyContainer: AppDependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    /// Builds and returns the root `MainTabView` containing the task list and profile tabs.
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
    
    /// Creates the add/edit task form.
    ///
    /// - Parameter task: The task to edit, or `nil` to show an empty form for a new task.
    /// - Returns: A type-erased `TaskDetailView`.
    func showTaskDetail(for task: TaskItem?) -> AnyView {
        let viewModel = dependencyContainer.makeTaskDetailViewModel(task: task)
        let view = TaskDetailView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }

    /// Creates the read-only task details screen.
    ///
    /// - Parameter task: The task to display.
    /// - Returns: A type-erased `TaskDetailsView`.
    func showTaskDetails(for task: TaskItem) -> AnyView {
        let viewModel = dependencyContainer.makeTaskDetailsViewModel(task: task)
        let view = TaskDetailsView(viewModel: viewModel, coordinator: self)
        return AnyView(view)
    }
}
