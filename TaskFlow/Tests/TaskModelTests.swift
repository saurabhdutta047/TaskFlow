import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskItem Model")
struct TaskItemTests {

    @Test("Default initialization sets expected values")
    func defaultInitialization() {
        let task = TaskItem(title: "Test Task")

        #expect(task.title == "Test Task")
        #expect(task.isCompleted == false)
    }

    @Test("Custom initialization preserves all values")
    func customInitialization() {
        let id = UUID()
        let date = Date()
        let task = TaskItem(id: id, title: "Custom Task", isCompleted: true, createdAt: date)

        #expect(task.id == id)
        #expect(task.title == "Custom Task")
        #expect(task.isCompleted == true)
        #expect(task.createdAt == date)
    }

    @Test("Tasks with same properties are equal")
    func equatable() {
        let id = UUID()
        let date = Date()
        let task1 = TaskItem(id: id, title: "Task", isCompleted: false, createdAt: date)
        let task2 = TaskItem(id: id, title: "Task", isCompleted: false, createdAt: date)

        #expect(task1 == task2)
    }

    @Test("Tasks with different IDs are not equal")
    func notEqualDifferentIds() {
        let task1 = TaskItem(title: "Task")
        let task2 = TaskItem(title: "Task")

        #expect(task1 != task2)
    }

    @Test("Tasks with different completion status are not equal")
    func notEqualDifferentCompletion() {
        let id = UUID()
        let date = Date()
        let task1 = TaskItem(id: id, title: "Task", isCompleted: false, createdAt: date)
        let task2 = TaskItem(id: id, title: "Task", isCompleted: true, createdAt: date)

        #expect(task1 != task2)
    }

    @Test("Encode and decode preserves all properties")
    func codable() throws {
        let task = TaskItem(title: "Test Task")

        let data = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(TaskItem.self, from: data)

        #expect(task.id == decoded.id)
        #expect(task.title == decoded.title)
        #expect(task.isCompleted == decoded.isCompleted)
    }

    @Test("Encode and decode array of tasks")
    func codableArray() throws {
        let tasks = [
            TaskItem(title: "Task 1"),
            TaskItem(title: "Task 2", isCompleted: true)
        ]

        let data = try JSONEncoder().encode(tasks)
        let decoded = try JSONDecoder().decode([TaskItem].self, from: data)

        #expect(decoded.count == 2)
        #expect(decoded[0].title == "Task 1")
        #expect(decoded[0].isCompleted == false)
        #expect(decoded[1].title == "Task 2")
        #expect(decoded[1].isCompleted == true)
    }

    @Test("Title is mutable")
    func mutableTitle() {
        var task = TaskItem(title: "Original")
        task.title = "Updated"

        #expect(task.title == "Updated")
    }

    @Test("isCompleted is mutable")
    func mutableIsCompleted() {
        var task = TaskItem(title: "Task")
        #expect(task.isCompleted == false)

        task.isCompleted = true
        #expect(task.isCompleted == true)

        task.isCompleted.toggle()
        #expect(task.isCompleted == false)
    }
}

@Suite("TaskFilter")
struct TaskFilterTests {

    @Test("Raw values match expected strings")
    func rawValues() {
        #expect(TaskFilter.all.rawValue == "All")
        #expect(TaskFilter.active.rawValue == "Active")
        #expect(TaskFilter.completed.rawValue == "Completed")
    }

    @Test("All cases contains all three filters")
    func allCases() {
        #expect(TaskFilter.allCases.count == 3)
        #expect(TaskFilter.allCases.contains(.all))
        #expect(TaskFilter.allCases.contains(.active))
        #expect(TaskFilter.allCases.contains(.completed))
    }

    @Test("Can initialize from raw value")
    func initFromRawValue() {
        #expect(TaskFilter(rawValue: "All") == .all)
        #expect(TaskFilter(rawValue: "Active") == .active)
        #expect(TaskFilter(rawValue: "Completed") == .completed)
        #expect(TaskFilter(rawValue: "Invalid") == nil)
    }
}
