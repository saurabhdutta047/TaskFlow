import Foundation

/// Use case protocol for retrieving all tasks from the repository.
protocol FetchTasksUseCase {
    /// Fetches every persisted task.
    /// - Returns: An array of `TaskItem` values.
    func execute() async throws -> [TaskItem]
}

/// Concrete implementation that delegates to a `TaskRepositoryProtocol`.
final class FetchTasksUseCaseImpl: FetchTasksUseCase {
    private let repository: TaskRepositoryProtocol
    
    /// - Parameter repository: The data source to fetch tasks from.
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [TaskItem] {
        return try await repository.fetchTasks()
    }
}
