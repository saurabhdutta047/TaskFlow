import Foundation

protocol TaskStorageServiceProtocol {
    func fetchTasks() throws -> [Task]
    func saveTasks(_ tasks: [Task]) throws
}

final class TaskStorageService: TaskStorageServiceProtocol {
    private let userDefaults: UserDefaults
    private let tasksKey = "tasks"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchTasks() throws -> [Task] {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            return []
        }
        return try JSONDecoder().decode([Task].self, from: data)
    }
    
    func saveTasks(_ tasks: [Task]) throws {
        let data = try JSONEncoder().encode(tasks)
        userDefaults.set(data, forKey: tasksKey)
    }
}
