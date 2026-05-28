import Foundation

/// Use case protocol for adding a new task to the repository.
protocol AddTaskUseCase {
    /// Persists a new task.
    /// - Parameter task: The `TaskItem` to add.
    func execute(_ task: TaskItem) async throws
}

/// Concrete implementation that delegates to a `TaskRepositoryProtocol`.
final class AddTaskUseCaseImpl: AddTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    /// - Parameter repository: The data source to add the task to.
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: TaskItem) async throws {
        try await repository.addTask(task)
    }
}
