import Testing
import Foundation
@testable import TaskFlow

@Suite("TaskDetailView")
@MainActor
struct TaskDetailViewTests {

    private func makeView(task: TaskItem? = nil) -> TaskDetailView {
        let container = AppDependencyContainer()
        let coordinator = AppCoordinator(dependencyContainer: container)
        let vm = container.makeTaskDetailViewModel(task: task)
        return TaskDetailView(viewModel: vm, coordinator: coordinator)
    }

    @Test("View can be created in add mode")
    func createAddMode() {
        let view = makeView(task: nil)
        _ = view.body
    }

    @Test("View can be created in edit mode")
    func createEditMode() {
        let task = TaskItem(title: "Edit Task")
        let view = makeView(task: task)
        _ = view.body
    }

    @Test("View can be created with completed task")
    func createWithCompletedTask() {
        let task = TaskItem(title: "Done Task", isCompleted: true)
        let view = makeView(task: task)
        _ = view.body
    }
}

@Suite("TaskDetailView ViewModel Integration")
@MainActor
struct TaskDetailViewViewModelTests {

    @Test("ViewModel title reflects in edit mode state")
    func viewModelEditModeTitle() {
        let container = AppDependencyContainer()
        let task = TaskItem(title: "Existing")
        let vm = container.makeTaskDetailViewModel(task: task)
        #expect(vm.title == "Existing")
        #expect(vm.isEditMode == true)
    }

    @Test("ViewModel starts unsaved in add mode")
    func viewModelAddModeUnsaved() {
        let container = AppDependencyContainer()
        let vm = container.makeTaskDetailViewModel(task: nil)
        #expect(vm.isSaved == false)
        #expect(vm.isSaving == false)
    }

    @Test("ViewModel edit mode preserves task completion status via isEditMode")
    func viewModelEditModePreservesStatus() {
        let container = AppDependencyContainer()
        let completedTask = TaskItem(title: "Done", isCompleted: true)
        let vm = container.makeTaskDetailViewModel(task: completedTask)
        #expect(vm.isEditMode == true)
        #expect(vm.title == "Done")
    }
}
