import Foundation

/// View model for the read-only task details screen.
///
/// Provides actions to toggle completion, delete the task, and reload
/// the latest data after an edit sheet is dismissed.
@MainActor
final class TaskDetailsViewModel: ObservableObject {
    /// The task being displayed (kept in sync with persisted state).
    @Published var task: TaskItem

    /// Set to `true` after a successful delete so the view can pop back.
    @Published var isDeleted = false

    /// A user-facing error message, or `nil` when there is no error.
    @Published var errorMessage: String?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

    /// - Parameters:
    ///   - task: The task to display.
    ///   - fetchTasksUseCase: Used to reload the task after edits.
    ///   - updateTaskUseCase: Used to toggle completion state.
    ///   - deleteTaskUseCase: Used to remove the task.
    init(
        task: TaskItem,
        fetchTasksUseCase: FetchTasksUseCase,
        updateTaskUseCase: UpdateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.task = task
        self.fetchTasksUseCase = fetchTasksUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
    }

    /// Flips the task's `isCompleted` flag and persists the change.
    func toggleCompletion() async {
        var updated = task
        updated.isCompleted.toggle()
        do {
            try await updateTaskUseCase.execute(updated)
            task = updated
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update: \(error.localizedDescription)"
        }
    }

    /// Permanently removes the task from storage.
    ///
    /// Sets `isDeleted` to `true` on success so the view can navigate back.
    func deleteTask() async {
        do {
            try await deleteTaskUseCase.execute(task)
            isDeleted = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }

    /// Re-fetches the task from storage to pick up any changes made in the edit sheet.
    func reloadTask() async {
        do {
            let allTasks = try await fetchTasksUseCase.execute()
            if let updated = allTasks.first(where: { $0.id == task.id }) {
                task = updated
            }
        } catch {
            // Silently handle reload failure
        }
    }
}
