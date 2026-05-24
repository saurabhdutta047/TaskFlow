import Testing
import Foundation
@testable import TaskFlow

// MARK: - TaskDetailSheetItem Tests

@Suite("TaskDetailSheetItem")
struct TaskDetailSheetItemTests {

    @Test("Each instance has a unique ID")
    func uniqueIds() {
        let item1 = TaskDetailSheetItem(task: nil)
        let item2 = TaskDetailSheetItem(task: nil)
        #expect(item1.id != item2.id)
    }

    @Test("Stores nil task for add mode")
    func nilTask() {
        let item = TaskDetailSheetItem(task: nil)
        #expect(item.task == nil)
    }

    @Test("Stores task for edit mode")
    func withTask() {
        let task = TaskItem(title: "Test")
        let item = TaskDetailSheetItem(task: task)
        #expect(item.task?.title == "Test")
        #expect(item.task?.id == task.id)
    }

    @Test("Preserves task properties")
    func preservesTaskProperties() {
        let task = TaskItem(title: "My Task", isCompleted: true)
        let item = TaskDetailSheetItem(task: task)
        #expect(item.task?.isCompleted == true)
        #expect(item.task?.title == "My Task")
    }

    @Test("Conforms to Identifiable")
    func identifiableConformance() {
        let item = TaskDetailSheetItem(task: nil)
        let _: UUID = item.id
    }
}

// MARK: - TaskListView Tests

@Suite("TaskListView")
@MainActor
struct TaskListViewTests {

    private func makeView() -> TaskListView {
        let container = AppDependencyContainer()
        let coordinator = AppCoordinator(dependencyContainer: container)
        let vm = container.makeTaskListViewModel()
        return TaskListView(viewModel: vm, coordinator: coordinator)
    }

    @Test("View can be created")
    func createView() {
        let view = makeView()
        _ = view.body
    }
}

// MARK: - TaskRowView Tests

@Suite("TaskRowView")
struct TaskRowViewTests {

    @Test("Can be created with active task")
    func createWithActiveTask() {
        let task = TaskItem(title: "Active", isCompleted: false)
        let row = TaskRowView(
            task: task,
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
        _ = row.body
    }

    @Test("Can be created with completed task")
    func createWithCompletedTask() {
        let task = TaskItem(title: "Done", isCompleted: true)
        let row = TaskRowView(
            task: task,
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
        _ = row.body
    }

    @Test("Row reflects task title")
    func reflectsTitle() {
        let task = TaskItem(title: "My Task Title")
        let row = TaskRowView(
            task: task,
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
        #expect(row.task.title == "My Task Title")
    }

    @Test("Row reflects task completion status")
    func reflectsCompletion() {
        let task = TaskItem(title: "Task", isCompleted: true)
        let row = TaskRowView(
            task: task,
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
        #expect(row.task.isCompleted == true)
    }

    @Test("Row reflects task creation date")
    func reflectsCreatedAt() {
        let date = Date(timeIntervalSince1970: 1000)
        let task = TaskItem(title: "Task", createdAt: date)
        let row = TaskRowView(
            task: task,
            onToggle: {},
            onTap: {},
            onDelete: {}
        )
        #expect(row.task.createdAt == date)
    }
}
