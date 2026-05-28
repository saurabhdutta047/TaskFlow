import Foundation

/// Concrete `TaskRepositoryProtocol` implementation backed by a storage service.
///
/// `TaskRepository` acts as the data-access layer between the domain use cases
/// and the underlying `TaskStorageServiceProtocol`. Each mutation (add, update,
/// delete) reads the current task list, applies the change, then writes the
/// updated list back to storage.
final class TaskRepository: TaskRepositoryProtocol {
    private let storageService: TaskStorageServiceProtocol
    
    /// - Parameter storageService: The low-level persistence provider.
    init(storageService: TaskStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    func fetchTasks() async throws -> [TaskItem] {
        return try storageService.fetchTasks()
    }
    
    /// Appends the given task to the persisted list.
    func addTask(_ task: TaskItem) async throws {
        var tasks = try storageService.fetchTasks()
        tasks.append(task)
        try storageService.saveTasks(tasks)
    }
    
    /// Replaces the task with a matching `id` in the persisted list.
    /// If no match is found the call is a no-op.
    func updateTask(_ task: TaskItem) async throws {
        var tasks = try storageService.fetchTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            try storageService.saveTasks(tasks)
        }
    }
    
    /// Removes all tasks with a matching `id` from the persisted list.
    func deleteTask(_ task: TaskItem) async throws {
        var tasks = try storageService.fetchTasks()
        tasks.removeAll { $0.id == task.id }
        try storageService.saveTasks(tasks)
    }
}
