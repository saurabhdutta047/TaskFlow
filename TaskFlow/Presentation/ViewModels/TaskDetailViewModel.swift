import Foundation

/// View model for the add/edit task form.
///
/// Operates in two modes determined by whether a `TaskItem` is provided:
/// - **Add mode** (`task == nil`): creates a new task on save.
/// - **Edit mode** (`task != nil`): updates the existing task on save.
///
/// Published properties are bound to the form fields in `TaskDetailView`.
@MainActor
final class TaskDetailViewModel: ObservableObject {
    /// The task title entered by the user.
    @Published var title: String = ""

    /// The selected priority level.
    @Published var priority: TaskPriority = .medium

    /// Free-form notes or details.
    @Published var notes: String = ""

    /// The selected due date.
    @Published var dueDate: Date = Date()

    /// The selected category.
    @Published var category: TaskCategory = .personal

    /// Whether a save operation is currently in flight.
    @Published var isSaving = false

    /// A user-facing error message, or `nil` when there is no error.
    @Published var errorMessage: String?

    /// Set to `true` after a successful save so the view can dismiss.
    @Published var isSaved = false

    private let task: TaskItem?
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase

    /// Whether the form is editing an existing task (vs. creating a new one).
    var isEditMode: Bool {
        task != nil
    }

    /// - Parameters:
    ///   - task: The task to edit, or `nil` to create a new task.
    ///   - addTaskUseCase: Use case for persisting a new task.
    ///   - updateTaskUseCase: Use case for updating an existing task.
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

    /// Validates the title and persists the task (add or update).
    ///
    /// On success, sets `isSaved` to `true` so the presenting view can dismiss.
    /// On failure, populates `errorMessage`.
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
