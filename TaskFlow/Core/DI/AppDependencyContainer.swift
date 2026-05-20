import Foundation

final class AppDependencyContainer {
    
    // MARK: - Storage Service
    lazy var taskStorageService: TaskStorageServiceProtocol = {
        TaskStorageService()
    }()
    
    // MARK: - Repository
    lazy var taskRepository: TaskRepositoryProtocol = {
        TaskRepository(storageService: taskStorageService)
    }()
    
    // MARK: - Use Cases
    lazy var fetchTasksUseCase: FetchTasksUseCase = {
        FetchTasksUseCaseImpl(repository: taskRepository)
    }()
    
    lazy var addTaskUseCase: AddTaskUseCase = {
        AddTaskUseCaseImpl(repository: taskRepository)
    }()
    
    lazy var updateTaskUseCase: UpdateTaskUseCase = {
        UpdateTaskUseCaseImpl(repository: taskRepository)
    }()
    
    lazy var deleteTaskUseCase: DeleteTaskUseCase = {
        DeleteTaskUseCaseImpl(repository: taskRepository)
    }()
    
    // MARK: - ViewModels
    @MainActor func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            fetchTasksUseCase: fetchTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
    }
    
    @MainActor func makeTaskDetailViewModel(task: TaskItem?) -> TaskDetailViewModel {
        TaskDetailViewModel(
            task: task,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase
        )
    }
    
    // MARK: - Coordinator
    @MainActor
    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(dependencyContainer: self)
    }
}

