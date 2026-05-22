import Testing
import Foundation
@testable import TaskFlow

@Suite("Use Cases")
struct UseCaseTests {

    private func makeRepository() -> MockRepository {
        return MockRepository()
    }

    @Suite("FetchTasksUseCase")
    struct FetchTests {

        @Test("Returns tasks from repository")
        func fetchTasks() async throws {
            let repo = MockRepository()
            repo.tasksToReturn = [TaskItem(title: "Task 1")]
            let useCase = FetchTasksUseCaseImpl(repository: repo)

            let tasks = try await useCase.execute()

            #expect(tasks.count == 1)
            #expect(tasks[0].title == "Task 1")
        }

        @Test("Returns empty array when no tasks")
        func fetchEmpty() async throws {
            let repo = MockRepository()
            let useCase = FetchTasksUseCaseImpl(repository: repo)

            let tasks = try await useCase.execute()

            #expect(tasks.isEmpty)
        }

        @Test("Propagates errors from repository")
        func fetchError() async {
            let repo = MockRepository()
            repo.shouldThrowError = true
            let useCase = FetchTasksUseCaseImpl(repository: repo)

            await #expect(throws: Error.self) {
                _ = try await useCase.execute()
            }
        }
    }

    @Suite("AddTaskUseCase")
    struct AddTests {

        @Test("Calls addTask on repository")
        func addTask() async throws {
            let repo = MockRepository()
            let useCase = AddTaskUseCaseImpl(repository: repo)
            let task = TaskItem(title: "New Task")

            try await useCase.execute(task)

            #expect(repo.addCalled == true)
            #expect(repo.lastAddedTask?.id == task.id)
        }

        @Test("Propagates errors from repository")
        func addError() async {
            let repo = MockRepository()
            repo.shouldThrowError = true
            let useCase = AddTaskUseCaseImpl(repository: repo)

            await #expect(throws: Error.self) {
                try await useCase.execute(TaskItem(title: "Task"))
            }
        }
    }

    @Suite("UpdateTaskUseCase")
    struct UpdateTests {

        @Test("Calls updateTask on repository")
        func updateTask() async throws {
            let repo = MockRepository()
            let useCase = UpdateTaskUseCaseImpl(repository: repo)
            let task = TaskItem(title: "Updated Task")

            try await useCase.execute(task)

            #expect(repo.updateCalled == true)
            #expect(repo.lastUpdatedTask?.id == task.id)
        }

        @Test("Propagates errors from repository")
        func updateError() async {
            let repo = MockRepository()
            repo.shouldThrowError = true
            let useCase = UpdateTaskUseCaseImpl(repository: repo)

            await #expect(throws: Error.self) {
                try await useCase.execute(TaskItem(title: "Task"))
            }
        }
    }

    @Suite("DeleteTaskUseCase")
    struct DeleteTests {

        @Test("Calls deleteTask on repository")
        func deleteTask() async throws {
            let repo = MockRepository()
            let useCase = DeleteTaskUseCaseImpl(repository: repo)
            let task = TaskItem(title: "Task to Delete")

            try await useCase.execute(task)

            #expect(repo.deleteCalled == true)
            #expect(repo.lastDeletedTask?.id == task.id)
        }

        @Test("Propagates errors from repository")
        func deleteError() async {
            let repo = MockRepository()
            repo.shouldThrowError = true
            let useCase = DeleteTaskUseCaseImpl(repository: repo)

            await #expect(throws: Error.self) {
                try await useCase.execute(TaskItem(title: "Task"))
            }
        }
    }
}

// MARK: - Mock

final class MockRepository: TaskRepositoryProtocol, @unchecked Sendable {
    var tasksToReturn: [TaskItem] = []
    var shouldThrowError = false
    var addCalled = false
    var updateCalled = false
    var deleteCalled = false
    var lastAddedTask: TaskItem?
    var lastUpdatedTask: TaskItem?
    var lastDeletedTask: TaskItem?

    func fetchTasks() async throws -> [TaskItem] {
        if shouldThrowError { throw MockError.testError }
        return tasksToReturn
    }

    func addTask(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockError.testError }
        addCalled = true
        lastAddedTask = task
    }

    func updateTask(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockError.testError }
        updateCalled = true
        lastUpdatedTask = task
    }

    func deleteTask(_ task: TaskItem) async throws {
        if shouldThrowError { throw MockError.testError }
        deleteCalled = true
        lastDeletedTask = task
    }
}

enum MockError: Error {
    case testError
}
