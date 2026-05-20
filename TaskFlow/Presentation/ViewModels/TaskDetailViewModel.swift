import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let task: Task?
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    
    var isEditMode: Bool {
        task != nil
    }
    
    init(
        task: Task?,
        addTaskUseCase: AddTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase
    ) {
        self.task = task
        self.addTaskUseCase = addTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.title = task?.title ?? ""
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
                try await updateTaskUseCase.execute(updatedTask)
            } else {
                let newTask = Task(title: title.trimmingCharacters(in: .whitespacesAndNewlines))
                try await addTaskUseCase.execute(newTask)
            }
            isSaved = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
        }
    }
}
