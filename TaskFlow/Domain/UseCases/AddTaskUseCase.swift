import Foundation

protocol AddTaskUseCase {
    func execute(_ task: TaskItem) async throws
}

final class AddTaskUseCaseImpl: AddTaskUseCase {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ task: TaskItem) async throws {
        try await repository.addTask(task)
    }
}
