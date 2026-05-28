import Foundation

/// Use case protocol for updating an existing task in the repository.
protocol UpdateTaskUseCase {
    /// Updates a task identified by its `id` with new values.
    /// - Parameter task: The `TaskItem` containing the updated fields.
    func execute(_ task: TaskItem) async throws
}

/// Concrete implementation that delegates to a `TaskRepositoryProtocol`.
final class UpdateTaskUseCaseImpl: UpdateTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    /// - Parameter repository: The data source to update the task in.
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: TaskItem) async throws {
        try await repository.updateTask(task)
    }
}
