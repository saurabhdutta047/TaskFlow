import Foundation

/// Use case protocol for removing a task from the repository.
protocol DeleteTaskUseCase {
    /// Deletes a task identified by its `id`.
    /// - Parameter task: The `TaskItem` to remove.
    func execute(_ task: TaskItem) async throws
}

/// Concrete implementation that delegates to a `TaskRepositoryProtocol`.
final class DeleteTaskUseCaseImpl: DeleteTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    /// - Parameter repository: The data source to delete the task from.
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: TaskItem) async throws {
        try await repository.deleteTask(task)
    }
}
