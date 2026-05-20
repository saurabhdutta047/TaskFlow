import Foundation

protocol DeleteTaskUseCase {
    func execute(_ task: Task) async throws
}

final class DeleteTaskUseCaseImpl: DeleteTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: Task) async throws {
        try await repository.deleteTask(task)
    }
}
