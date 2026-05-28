import Foundation

/// Defines the low-level contract for persisting and retrieving tasks.
///
/// Implementations handle the encoding/decoding of `TaskItem` arrays
/// to and from a backing store. The default implementation uses
/// `UserDefaults` with JSON serialization.
protocol TaskStorageServiceProtocol {
    /// Reads all tasks from the backing store.
    /// - Returns: An array of decoded `TaskItem` values, or an empty array if none exist.
    func fetchTasks() throws -> [TaskItem]

    /// Writes the full task list to the backing store, replacing any previous data.
    /// - Parameter tasks: The complete array of `TaskItem` values to persist.
    func saveTasks(_ tasks: [TaskItem]) throws
}

/// `UserDefaults`-backed storage service that serializes tasks as JSON.
///
/// This is the default persistence layer used throughout the app.
/// A custom `UserDefaults` suite can be injected for testing isolation.
final class TaskStorageService: TaskStorageServiceProtocol {
    private let userDefaults: UserDefaults
    private let tasksKey = "tasks"
    
    /// - Parameter userDefaults: The `UserDefaults` instance to use. Defaults to `.standard`.
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
