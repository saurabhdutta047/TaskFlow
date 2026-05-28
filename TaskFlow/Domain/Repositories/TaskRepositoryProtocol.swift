import Foundation

/// Defines the contract for task data access.
///
/// This protocol abstracts the underlying persistence mechanism so that
/// view models and use cases remain decoupled from storage details.
/// The concrete implementation is `TaskRepository`, which delegates to
/// a `TaskStorageServiceProtocol` for encoding/decoding.
///
/// All methods are asynchronous and throwing, allowing implementations
/// to perform I/O without blocking the main thread.
protocol TaskRepositoryProtocol {
    /// Retrieves all stored tasks.
    /// - Returns: An array of every persisted `TaskItem`.
    func fetchTasks() async throws -> [TaskItem]

    /// Persists a new task.
    /// - Parameter task: The `TaskItem` to store.
    func addTask(_ task: TaskItem) async throws

    /// Updates an existing task identified by its `id`.
    /// - Parameter task: The `TaskItem` containing the updated values.
    func updateTask(_ task: TaskItem) async throws

    /// Removes an existing task identified by its `id`.
    /// - Parameter task: The `TaskItem` to delete.
    func deleteTask(_ task: TaskItem) async throws
}
