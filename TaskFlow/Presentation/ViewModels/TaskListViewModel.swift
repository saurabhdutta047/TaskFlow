import Foundation
import Combine

/// View model that drives the main task list screen.
///
/// Manages loading, filtering, toggling completion, and deleting tasks.
/// The initial load shows a loading indicator; subsequent refreshes
/// update silently to prevent UI flickering.
@MainActor
final class TaskListViewModel: ObservableObject {
    /// All tasks currently persisted.
    @Published var tasks: [TaskItem] = []

    /// The active filter controlling which tasks are visible.
    @Published var filter: TaskFilter = .all

    /// Whether the initial task load is in progress (controls the spinner).
    @Published var isLoading = false

    /// A user-facing error message, or `nil` when there is no error.
    @Published var errorMessage: String?
    
    private let fetchTasksUseCase: FetchTasksUseCase
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    
    /// - Parameters:
    ///   - fetchTasksUseCase: Use case for retrieving tasks.
    ///   - addTaskUseCase: Use case for creating tasks.
    ///   - updateTaskUseCase: Use case for updating tasks.
    ///   - deleteTaskUseCase: Use case for removing tasks.
    init(
        fetchTasksUseCase: FetchTasksUseCase,
        addTaskUseCase: AddTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
    }
    
    /// Returns the task list sorted by creation date (newest first),
    /// filtered according to the current `filter` value.
    var filteredTasks: [TaskItem] {
        switch filter {
        case .all:
            return tasks.sorted { $0.createdAt > $1.createdAt }
        case .active:
            return tasks.filter { !$0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
        case .completed:
            return tasks.filter { $0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    /// Fetches all tasks from the repository.
    ///
    /// The loading spinner is only shown on the initial load (when `tasks`
    /// is empty) to avoid flickering on subsequent refreshes.
    func loadTasks() async {
        let isInitialLoad = tasks.isEmpty
        if isInitialLoad { isLoading = true }
        defer { if isInitialLoad { isLoading = false } }
        
        do {
            tasks = try await fetchTasksUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
    }
    
    /// Toggles the completion state of the given task and refreshes the list.
    /// - Parameter task: The task whose `isCompleted` flag will be flipped.
    func toggleTaskCompletion(_ task: TaskItem) async {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        
        do {
            try await updateTaskUseCase.execute(updatedTask)
            await loadTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }
    
    /// Permanently removes the given task and refreshes the list.
    /// - Parameter task: The task to delete.
    func deleteTask(_ task: TaskItem) async {
        do {
            try await deleteTaskUseCase.execute(task)
            await loadTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }
}
