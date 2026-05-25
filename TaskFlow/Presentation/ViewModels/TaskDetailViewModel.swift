import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var priority: TaskPriority = .medium
    @Published var notes: String = ""
    @Published var dueDate: Date = Date()
    @Published var category: TaskCategory = .personal
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var isSaved = false

    private let task: TaskItem?
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase

    var isEditMode: Bool {
        task != nil
    }

    init(
        task: TaskItem?,
        addTaskUseCase: AddTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase
    ) {
        self.task = task
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.title = task?.title ?? ""
        self.priority = task?.priority ?? .medium
        self.notes = task?.notes ?? ""
        self.dueDate = task?.dueDate ?? Date()
        self.category = task?.category ?? .personal
    }

    func saveTask() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Task title cannot be empty"
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            if let existingTask = task {
                var updatedTask = existingTask
                updatedTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedTask.priority = priority
                updatedTask.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedTask.dueDate = dueDate
                updatedTask.category = category
                try await updateTaskUseCase.execute(updatedTask)
            } else {
                let newTask = TaskItem(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    priority: priority,
                    notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                    dueDate: dueDate,
                    category: category
                )
                try await addTaskUseCase.execute(newTask)
            }
            isSaved = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
        }
    }
}
