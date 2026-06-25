import Foundation
import SwiftData

/// Defines the low-level contract for persisting and retrieving tasks.
///
/// Implementations handle the storage and retrieval of `TaskItem` objects
/// to and from a backing store. The default implementation uses
/// SwiftData for efficient database persistence.
protocol TaskStorageServiceProtocol {
    /// Reads all tasks from the backing store.
    /// - Returns: An array of `TaskItem` values, or an empty array if none exist.
    func fetchTasks() throws -> [TaskItem]

    /// Writes the full task list to the backing store, replacing any previous data.
    /// - Parameter tasks: The complete array of `TaskItem` values to persist.
    func saveTasks(_ tasks: [TaskItem]) throws
}

/// SwiftData-backed storage service that manages task persistence.
///
/// This is the default persistence layer used throughout the app.
/// It uses SwiftData's ModelContext for efficient database operations.
/// A custom `ModelContext` can be injected for testing isolation.
final class TaskStorageService: TaskStorageServiceProtocol {
    private let modelContext: ModelContext

    /// - Parameter modelContext: The SwiftData ModelContext to use for database operations.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchTasks() throws -> [TaskItem] {
        var descriptor = FetchDescriptor<TaskItem>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        return try modelContext.fetch(descriptor)
    }

    func saveTasks(_ tasks: [TaskItem]) throws {
        // Delete all existing tasks
        let deleteDescriptor = FetchDescriptor<TaskItem>()
        let existingTasks = try modelContext.fetch(deleteDescriptor)
        for task in existingTasks {
            modelContext.delete(task)
        }

        // Insert new tasks
        for task in tasks {
            modelContext.insert(task)
        }

        try modelContext.save()
    }
}
