import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    private let storageService: TaskStorageServiceProtocol
    
    init(storageService: TaskStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    func fetchTasks() async throws -> [Task] {
        return try storageService.fetchTasks()
    }
    
    func addTask(_ task: Task) async throws {
        var tasks = try storageService.fetchTasks()
        tasks.append(task)
        try storageService.saveTasks(tasks)
    }
    
    func updateTask(_ task: Task) async throws {
        var tasks = try storageService.fetchTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            try storageService.saveTasks(tasks)
        }
    }
    
    func deleteTask(_ task: Task) async throws {
        var tasks = try storageService.fetchTasks()
        tasks.removeAll { $0.id == task.id }
        try storageService.saveTasks(tasks)
    }
}
