import Foundation
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var filter: TaskFilter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchTasksUseCase: FetchTasksUseCase
    private let addTaskUseCase: AddTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    
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
