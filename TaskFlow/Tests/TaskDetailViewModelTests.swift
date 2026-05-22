import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskDetailViewModel")
@MainActor
struct TaskDetailViewModelTests {

    private func makeViewModel(
        task: TaskItem? = nil
    ) -> (TaskDetailViewModel, MockDetailAddUseCase, MockDetailUpdateUseCase) {
        let add = MockDetailAddUseCase()
        let update = MockDetailUpdateUseCase()
        let vm = TaskDetailViewModel(task: task, addTaskUseCase: add, updateTaskUseCase: update)
        return (vm, add, update)
    }

    // MARK: - Initialization

    @Test("Init without task sets empty title and add mode")
    func initAddMode() {
        let (vm, _, _) = makeViewModel(task: nil)

        #expect(vm.title == "")
        #expect(vm.isEditMode == false)
        #expect(vm.isSaved == false)
        #expect(vm.isSaving == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("Init with task sets title and edit mode")
    func initEditMode() {
        let task = TaskItem(title: "Existing Task")
        let (vm, _, _) = makeViewModel(task: task)

        #expect(vm.title == "Existing Task")
        #expect(vm.isEditMode == true)
    }

    // MARK: - Save (Add mode)

    @Test("Save in add mode calls add use case")
    func saveNewTask() async {
        let (vm, add, _) = makeViewModel(task: nil)
        vm.title = "New Task"

        await vm.saveTask()

        #expect(add.called == true)
        #expect(add.lastTask?.title == "New Task")
        #expect(vm.isSaved == true)
        #expect(vm.errorMessage == nil)
        #expect(vm.isSaving == false)
    }

    @Test("Save trims whitespace from title")
    func saveTrimmedTitle() async {
        let (vm, add, _) = makeViewModel(task: nil)
        vm.title = "  Trimmed Task  "

        await vm.saveTask()

        #expect(add.lastTask?.title == "Trimmed Task")
    }

    @Test("Save with empty title sets error and does not call use case")
    func saveEmptyTitle() async {
        let (vm, add, _) = makeViewModel(task: nil)
        vm.title = ""

        await vm.saveTask()

        #expect(add.called == false)
        #expect(vm.isSaved == false)
        #expect(vm.errorMessage == "Task title cannot be empty")
    }

    @Test("Save with whitespace-only title sets error")
    func saveWhitespaceTitle() async {
        let (vm, add, _) = makeViewModel(task: nil)
        vm.title = "   "

        await vm.saveTask()

        #expect(add.called == false)
        #expect(vm.isSaved == false)
        #expect(vm.errorMessage == "Task title cannot be empty")
    }

    @Test("Save sets error message on add failure")
    func saveAddFailure() async {
        let (vm, add, _) = makeViewModel(task: nil)
        add.shouldThrowError = true
        vm.title = "Task"

        await vm.saveTask()

        #expect(vm.isSaved == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.isSaving == false)
    }

    // MARK: - Save (Edit mode)

    @Test("Save in edit mode calls update use case")
    func saveExistingTask() async {
        let task = TaskItem(title: "Original")
        let (vm, _, update) = makeViewModel(task: task)
        vm.title = "Updated"

        await vm.saveTask()

        #expect(update.called == true)
        #expect(update.lastTask?.title == "Updated")
        #expect(update.lastTask?.id == task.id)
        #expect(vm.isSaved == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Save in edit mode preserves task ID")
    func savePreservesId() async {
        let task = TaskItem(title: "Original")
        let (vm, _, update) = makeViewModel(task: task)
        vm.title = "Changed"

        await vm.saveTask()

        #expect(update.lastTask?.id == task.id)
    }

    @Test("Save sets error message on update failure")
    func saveUpdateFailure() async {
        let task = TaskItem(title: "Original")
        let (vm, _, update) = makeViewModel(task: task)
        update.shouldThrowError = true
        vm.title = "Updated"

        await vm.saveTask()

        #expect(vm.isSaved == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.isSaving == false)
    }
}

// MARK: - Mocks

final class MockDetailAddUseCase: AddTaskUseCase, @unchecked Sendable {
    var called = false
    var lastTask: TaskItem?
    var shouldThrowError = false

    func execute(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockDetailError.testError }
        called = true
        lastTask = task
    }
}

final class MockDetailUpdateUseCase: UpdateTaskUseCase, @unchecked Sendable {
    var called = false
    var lastTask: TaskItem?
    var shouldThrowError = false

    func execute(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockDetailError.testError }
        called = true
        lastTask = task
    }
}

enum MockDetailError: Error {
    case testError
}
