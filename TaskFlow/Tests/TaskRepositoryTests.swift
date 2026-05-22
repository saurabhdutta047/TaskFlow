import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskRepository")
struct TaskRepositoryTests {

    private func makeRepository() -> (TaskRepository, MockStorageService) {
        let storage = MockStorageService()
        let repository = TaskRepository(storageService: storage)
        return (repository, storage)
    }

    @Test("Fetch returns tasks from storage")
    func fetchTasks() async throws {
        let (repo, storage) = makeRepository()
        let expected = [TaskItem(title: "Task 1"), TaskItem(title: "Task 2")]
        storage.tasksToReturn = expected

        let tasks = try await repo.fetchTasks()

        #expect(tasks.count == 2)
        #expect(tasks[0].title == "Task 1")
        #expect(tasks[1].title == "Task 2")
    }

    @Test("Add appends task to storage")
    func addTask() async throws {
        let (repo, storage) = makeRepository()
        let task = TaskItem(title: "New Task")

        try await repo.addTask(task)

        #expect(storage.savedTasks.count == 1)
        #expect(storage.savedTasks[0].id == task.id)
    }

    @Test("Add preserves existing tasks")
    func addPreservesExisting() async throws {
        let (repo, storage) = makeRepository()
        let existing = TaskItem(title: "Existing")
        storage.tasksToReturn = [existing]

        let newTask = TaskItem(title: "New")
        try await repo.addTask(newTask)

        #expect(storage.savedTasks.count == 2)
        #expect(storage.savedTasks[0].id == existing.id)
        #expect(storage.savedTasks[1].id == newTask.id)
    }

    @Test("Update modifies matching task in storage")
    func updateTask() async throws {
        let (repo, storage) = makeRepository()
        let task = TaskItem(title: "Original")
        storage.tasksToReturn = [task]

        var updated = task
        updated.title = "Updated"
        try await repo.updateTask(updated)

        #expect(storage.savedTasks.count == 1)
        #expect(storage.savedTasks[0].title == "Updated")
    }

    @Test("Update does not modify storage when task not found")
    func updateNonExistent() async throws {
        let (repo, storage) = makeRepository()
        let existing = TaskItem(title: "Existing")
        storage.tasksToReturn = [existing]

        let unrelated = TaskItem(title: "Unrelated")
        try await repo.updateTask(unrelated)

        #expect(storage.savedTasks.isEmpty)
    }

    @Test("Delete removes matching task from storage")
    func deleteTask() async throws {
        let (repo, storage) = makeRepository()
        let task1 = TaskItem(title: "Task 1")
        let task2 = TaskItem(title: "Task 2")
        storage.tasksToReturn = [task1, task2]

        try await repo.deleteTask(task1)

        #expect(storage.savedTasks.count == 1)
        #expect(storage.savedTasks[0].id == task2.id)
    }

    @Test("Delete non-existent task leaves storage unchanged")
    func deleteNonExistent() async throws {
        let (repo, storage) = makeRepository()
        let existing = TaskItem(title: "Existing")
        storage.tasksToReturn = [existing]

        let unrelated = TaskItem(title: "Unrelated")
        try await repo.deleteTask(unrelated)

        #expect(storage.savedTasks.count == 1)
        #expect(storage.savedTasks[0].id == existing.id)
    }
}

// MARK: - Mock

final class MockStorageService: TaskStorageServiceProtocol {
    var tasksToReturn: [TaskItem] = []
    var savedTasks: [TaskItem] = []

    func fetchTasks() throws -> [TaskItem] {
        return tasksToReturn
    }

    func saveTasks(_ tasks: [TaskItem]) throws {
        savedTasks = tasks
    }
}
