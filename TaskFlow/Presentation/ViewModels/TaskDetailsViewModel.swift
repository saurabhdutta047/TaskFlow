import Foundation

@MainActor
final class TaskDetailsViewModel: ObservableObject {
    @Published var task: TaskItem
    @Published var isDeleted = false
    @Published var errorMessage: String?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

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

    func deleteTask() async {
        do {
            try await deleteTaskUseCase.execute(task)
            isDeleted = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }

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
