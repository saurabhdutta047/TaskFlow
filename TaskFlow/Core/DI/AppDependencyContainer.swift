import Foundation

/// Central dependency injection container for the application.
///
/// Owns the singleton instances of the storage service, repository, and
/// use cases (created lazily). Provides factory methods that produce
/// fresh view model instances wired to the shared use cases.
///
/// Usage: Create a single `AppDependencyContainer` at app launch and
/// pass it to `AppCoordinator`.
final class AppDependencyContainer {
    
    // MARK: - Storage Service

    /// The low-level persistence service (backed by `UserDefaults`).
    lazy var taskStorageService: TaskStorageServiceProtocol = {
        TaskStorageService()
    }()
    
    // MARK: - Repository

    /// The task repository that bridges use cases and storage.
    lazy var taskRepository: TaskRepositoryProtocol = {
        TaskRepository(storageService: taskStorageService)
    }()
    
    // MARK: - Use Cases

    /// Use case for fetching all persisted tasks.
    lazy var fetchTasksUseCase: FetchTasksUseCase = {
        FetchTasksUseCaseImpl(repository: taskRepository)
    }()

    /// Use case for adding a new task.
    lazy var addTaskUseCase: AddTaskUseCase = {
        AddTaskUseCaseImpl(repository: taskRepository)
    }()

    /// Use case for updating an existing task.
    lazy var updateTaskUseCase: UpdateTaskUseCase = {
        UpdateTaskUseCaseImpl(repository: taskRepository)
    }()

    /// Use case for deleting a task.
    lazy var deleteTaskUseCase: DeleteTaskUseCase = {
        DeleteTaskUseCaseImpl(repository: taskRepository)
    }()
    
    // MARK: - ViewModel Factories

    /// Creates a new `TaskListViewModel` wired to all CRUD use cases.
    @MainActor func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            fetchTasksUseCase: fetchTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
    }

    /// Creates a new `TaskDetailViewModel` for add or edit mode.
    /// - Parameter task: Pass `nil` for add mode, or an existing task for edit mode.
    @MainActor func makeTaskDetailViewModel(task: TaskItem?) -> TaskDetailViewModel {
        TaskDetailViewModel(
            task: task,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase
        )
    }

    /// Creates a new `TaskDetailsViewModel` for the read-only details screen.
    /// - Parameter task: The task to display.
    @MainActor func makeTaskDetailsViewModel(task: TaskItem) -> TaskDetailsViewModel {
        TaskDetailsViewModel(
            task: task,
            fetchTasksUseCase: fetchTasksUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
    }

    /// Creates a new `UserProfileViewModel` for the profile/settings screen.
    @MainActor func makeUserProfileViewModel() -> UserProfileViewModel {
        UserProfileViewModel(fetchTasksUseCase: fetchTasksUseCase)
    }

    // MARK: - Coordinator

    /// Creates the root `AppCoordinator` for the application.
    @MainActor
    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(dependencyContainer: self)
    }
}
