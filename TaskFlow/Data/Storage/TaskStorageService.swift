import Foundation

protocol TaskStorageServiceProtocol {
    func fetchTasks() throws -> [TaskItem]
    func saveTasks(_ tasks: [TaskItem]) throws
}

final class TaskStorageService: TaskStorageServiceProtocol {
    private let userDefaults: UserDefaults
    private let tasksKey = "tasks"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchTasks() throws -> [TaskItem] {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            return []
        }
        return try JSONDecoder().decode([TaskItem].self, from: data)
    }
    
    func saveTasks(_ tasks: [TaskItem]) throws {
        let data = try JSONEncoder().encode(tasks)
        userDefaults.set(data, forKey: tasksKey)
    }
}
