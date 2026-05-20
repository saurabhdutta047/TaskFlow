import Foundation

protocol FetchTasksUseCase {
    func execute() async throws -> [Task]
}

final class FetchTasksUseCaseImpl: FetchTasksUseCase {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Task] {
        return try await repository.fetchTasks()
    }
}
