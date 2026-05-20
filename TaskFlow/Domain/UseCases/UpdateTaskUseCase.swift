import Foundation

protocol UpdateTaskUseCase {
    func execute(_ task: TaskItem) async throws
}

final class UpdateTaskUseCaseImpl: UpdateTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: TaskItem) async throws {
        try await repository.updateTask(task)
    }
}
