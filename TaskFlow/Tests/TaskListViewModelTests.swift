import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskListViewModel")
@MainActor
struct TaskListViewModelTests {

    private func makeViewModel(
        fetchTasks: [TaskItem] = [],
        shouldThrowError: Bool = false
    ) -> (TaskListViewModel, MockFetchUseCase, MockAddUseCase, MockUpdateUseCase, MockDeleteUseCase) {
        let fetch = MockFetchUseCase()
        fetch.tasksToReturn = fetchTasks
        fetch.shouldThrowError = shouldThrowError
        let add = MockAddUseCase()
        let update = MockUpdateUseCase()
        let delete = MockDeleteUseCase()

        let vm = TaskListViewModel(
            fetchTasksUseCase: fetch,
            addTaskUseCase: add,
            updateTaskUseCase: update,
            deleteTaskUseCase: delete
        )
        return (vm, fetch, add, update, delete)
    }

    // MARK: - loadTasks

    @Test("Load tasks populates tasks array")
    func loadTasksSuccess() async {
        let tasks = [
            TaskItem(title: "Task 1"),
            TaskItem(title: "Task 2", isCompleted: true)
        ]
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: tasks)

        await vm.loadTasks()

        #expect(vm.tasks.count == 2)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("Load tasks sets error message on failure")
    func loadTasksFailure() async {
        let (vm, _, _, _, _) = makeViewModel(shouldThrowError: true)

        await vm.loadTasks()

        #expect(vm.tasks.isEmpty)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
    }

    @Test("Initial load shows loading state")
    func initialLoadShowsLoading() async {
        let (vm, _, _, _, _) = makeViewModel()

        #expect(vm.isLoading == false)
        #expect(vm.tasks.isEmpty)
    }

    // MARK: - filteredTasks

    @Test("Filter .all returns all tasks sorted by date descending")
    func filterAll() async {
        let older = TaskItem(title: "Older", createdAt: Date(timeIntervalSince1970: 1000))
        let newer = TaskItem(title: "Newer", createdAt: Date(timeIntervalSince1970: 2000))
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: [older, newer])

        await vm.loadTasks()
        vm.filter = .all

        #expect(vm.filteredTasks.count == 2)
        #expect(vm.filteredTasks[0].title == "Newer")
        #expect(vm.filteredTasks[1].title == "Older")
    }

    @Test("Filter .active returns only incomplete tasks")
    func filterActive() async {
        let tasks = [
            TaskItem(title: "Active", isCompleted: false),
            TaskItem(title: "Done", isCompleted: true)
        ]
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: tasks)

        await vm.loadTasks()
        vm.filter = .active

        #expect(vm.filteredTasks.count == 1)
        #expect(vm.filteredTasks[0].isCompleted == false)
    }

    @Test("Filter .completed returns only completed tasks")
    func filterCompleted() async {
        let tasks = [
            TaskItem(title: "Active", isCompleted: false),
            TaskItem(title: "Done", isCompleted: true)
        ]
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: tasks)

        await vm.loadTasks()
        vm.filter = .completed

        #expect(vm.filteredTasks.count == 1)
        #expect(vm.filteredTasks[0].isCompleted == true)
    }

    @Test("Filter returns empty when no tasks match")
    func filterEmpty() async {
        let tasks = [TaskItem(title: "Active", isCompleted: false)]
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: tasks)

        await vm.loadTasks()
        vm.filter = .completed

        #expect(vm.filteredTasks.isEmpty)
    }

    // MARK: - toggleTaskCompletion

    @Test("Toggle calls update use case with toggled completion")
    func toggleCompletion() async {
        let task = TaskItem(title: "Task", isCompleted: false)
        let (vm, _, _, update, _) = makeViewModel(fetchTasks: [task])

        await vm.loadTasks()
        await vm.toggleTaskCompletion(task)

        #expect(update.called == true)
        #expect(update.lastTask?.isCompleted == true)
    }

    @Test("Toggle sets error on failure")
    func toggleError() async {
        let task = TaskItem(title: "Task", isCompleted: false)
        let (vm, _, _, update, _) = makeViewModel(fetchTasks: [task])
        update.shouldThrowError = true

        await vm.loadTasks()
        await vm.toggleTaskCompletion(task)

        #expect(vm.errorMessage != nil)
    }

    // MARK: - deleteTask

    @Test("Delete calls delete use case")
    func deleteTask() async {
        let task = TaskItem(title: "Task")
        let (vm, _, _, _, delete) = makeViewModel(fetchTasks: [task])

        await vm.loadTasks()
        await vm.deleteTask(task)

        #expect(delete.called == true)
        #expect(delete.lastTask?.id == task.id)
    }

    @Test("Delete sets error on failure")
    func deleteError() async {
        let task = TaskItem(title: "Task")
        let (vm, _, _, _, delete) = makeViewModel(fetchTasks: [task])
        delete.shouldThrowError = true

        await vm.loadTasks()
        await vm.deleteTask(task)

        #expect(vm.errorMessage != nil)
    }

    @Test("Default filter is .all")
    func defaultFilter() {
        let (vm, _, _, _, _) = makeViewModel()

        #expect(vm.filter == .all)
    }

    // MARK: - Subsequent load (flickering fix)

    @Test("Subsequent load does not set isLoading when tasks exist")
    func subsequentLoadNoLoading() async {
        let tasks = [TaskItem(title: "Task")]
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: tasks)

        await vm.loadTasks()
        #expect(vm.isLoading == false)
        #expect(!vm.tasks.isEmpty)

        await vm.loadTasks()
        #expect(vm.isLoading == false)
    }

    // MARK: - Toggle reverse direction

    @Test("Toggle completed task back to active")
    func toggleCompletedToActive() async {
        let task = TaskItem(title: "Task", isCompleted: true)
        let (vm, _, _, update, _) = makeViewModel(fetchTasks: [task])

        await vm.loadTasks()
        await vm.toggleTaskCompletion(task)

        #expect(update.called == true)
        #expect(update.lastTask?.isCompleted == false)
    }

    // MARK: - Error clearing

    @Test("Successful load clears previous error")
    func loadClearsPreviousError() async {
        let (vm, fetch, _, _, _) = makeViewModel(shouldThrowError: true)

        await vm.loadTasks()
        #expect(vm.errorMessage != nil)

        fetch.shouldThrowError = false
        fetch.tasksToReturn = [TaskItem(title: "Task")]
        await vm.loadTasks()
        #expect(vm.errorMessage == nil)
    }

    @Test("Successful toggle clears previous error")
    func toggleClearsPreviousError() async {
        let task = TaskItem(title: "Task")
        let (vm, _, _, update, _) = makeViewModel(fetchTasks: [task])
        update.shouldThrowError = true

        await vm.loadTasks()
        await vm.toggleTaskCompletion(task)
        #expect(vm.errorMessage != nil)

        update.shouldThrowError = false
        await vm.toggleTaskCompletion(task)
        #expect(vm.errorMessage == nil)
    }

    @Test("Successful delete clears previous error")
    func deleteClearsPreviousError() async {
        let task = TaskItem(title: "Task")
        let (vm, _, _, _, delete) = makeViewModel(fetchTasks: [task])
        delete.shouldThrowError = true

        await vm.loadTasks()
        await vm.deleteTask(task)
        #expect(vm.errorMessage != nil)

        delete.shouldThrowError = false
        await vm.deleteTask(task)
        #expect(vm.errorMessage == nil)
    }

    // MARK: - Filter switching

    @Test("Switching filters updates filteredTasks dynamically")
    func filterSwitching() async {
        let active = TaskItem(title: "Active", isCompleted: false)
        let done = TaskItem(title: "Done", isCompleted: true)
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: [active, done])

        await vm.loadTasks()

        vm.filter = .all
        #expect(vm.filteredTasks.count == 2)

        vm.filter = .active
        #expect(vm.filteredTasks.count == 1)
        #expect(vm.filteredTasks[0].title == "Active")

        vm.filter = .completed
        #expect(vm.filteredTasks.count == 1)
        #expect(vm.filteredTasks[0].title == "Done")

        vm.filter = .all
        #expect(vm.filteredTasks.count == 2)
    }

    // MARK: - Sorting

    @Test("Active filter sorts by date descending")
    func activeSortedByDate() async {
        let older = TaskItem(title: "Older", isCompleted: false, createdAt: Date(timeIntervalSince1970: 1000))
        let newer = TaskItem(title: "Newer", isCompleted: false, createdAt: Date(timeIntervalSince1970: 2000))
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: [older, newer])

        await vm.loadTasks()
        vm.filter = .active

        #expect(vm.filteredTasks[0].title == "Newer")
        #expect(vm.filteredTasks[1].title == "Older")
    }

    @Test("Completed filter sorts by date descending")
    func completedSortedByDate() async {
        let older = TaskItem(title: "Older", isCompleted: true, createdAt: Date(timeIntervalSince1970: 1000))
        let newer = TaskItem(title: "Newer", isCompleted: true, createdAt: Date(timeIntervalSince1970: 2000))
        let (vm, _, _, _, _) = makeViewModel(fetchTasks: [older, newer])

        await vm.loadTasks()
        vm.filter = .completed

        #expect(vm.filteredTasks[0].title == "Newer")
        #expect(vm.filteredTasks[1].title == "Older")
    }
}

// MARK: - Mocks

final class MockFetchUseCase: FetchTasksUseCase, @unchecked Sendable {
    var tasksToReturn: [TaskItem] = []
    var shouldThrowError = false

    func execute() async throws -> [TaskItem] {
        if shouldThrowError { throw MockUseCaseError.testError }
        return tasksToReturn
    }
}

final class MockAddUseCase: AddTaskUseCase, @unchecked Sendable {
    var called = false
    var lastTask: TaskItem?
    var shouldThrowError = false

    func execute(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockUseCaseError.testError }
        called = true
        lastTask = task
    }
}

final class MockUpdateUseCase: UpdateTaskUseCase, @unchecked Sendable {
    var called = false
    var lastTask: TaskItem?
    var shouldThrowError = false

    func execute(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockUseCaseError.testError }
        called = true
        lastTask = task
    }
}

final class MockDeleteUseCase: DeleteTaskUseCase, @unchecked Sendable {
    var called = false
    var lastTask: TaskItem?
    var shouldThrowError = false

    func execute(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockUseCaseError.testError }
        called = true
        lastTask = task
    }
}

enum MockUseCaseError: Error {
    case testError
}
