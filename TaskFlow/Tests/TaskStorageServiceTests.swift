import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskStorageService")
struct TaskStorageServiceTests {

    private func makeService() -> TaskStorageService {
        let suiteName = "TaskStorageServiceTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return TaskStorageService(userDefaults: defaults)
    }

    @Test("Fetch returns empty array when no tasks stored")
    func fetchEmpty() throws {
        let service = makeService()

        let tasks = try service.fetchTasks()

        #expect(tasks.isEmpty)
    }

    @Test("Save and fetch round-trips tasks correctly")
    func saveAndFetch() throws {
        let service = makeService()
        let task1 = TaskItem(title: "Task 1")
        let task2 = TaskItem(title: "Task 2")

        try service.saveTasks([task1, task2])
        let fetched = try service.fetchTasks()

        #expect(fetched.count == 2)
        let fetchedIds = Set(fetched.map(\.id))
        #expect(fetchedIds.contains(task1.id))
        #expect(fetchedIds.contains(task2.id))
    }

    @Test("Save overwrites previously stored tasks")
    func saveOverwrites() throws {
        let service = makeService()
        let task1 = TaskItem(title: "Task 1")
        let task2 = TaskItem(title: "Task 2")

        try service.saveTasks([task1])
        try service.saveTasks([task2])

        let fetched = try service.fetchTasks()

        #expect(fetched.count == 1)
        #expect(fetched[0].id == task2.id)
    }

    @Test("Save empty array clears all tasks")
    func saveEmptyClears() throws {
        let service = makeService()
        let task = TaskItem(title: "Task")

        try service.saveTasks([task])
        try service.saveTasks([])

        let fetched = try service.fetchTasks()

        #expect(fetched.isEmpty)
    }

    @Test("Preserves task properties through save and fetch")
    func preservesProperties() throws {
        let service = makeService()
        let task = TaskItem(title: "Important Task", isCompleted: true)

        try service.saveTasks([task])
        let fetched = try service.fetchTasks()

        #expect(fetched.count == 1)
        #expect(fetched[0].title == "Important Task")
        #expect(fetched[0].isCompleted == true)
        #expect(fetched[0].id == task.id)
        #expect(fetched[0].createdAt == task.createdAt)
    }
}
