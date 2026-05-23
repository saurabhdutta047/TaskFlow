import Testing
import Foundation
@testable import TaskFlow

@Suite("AppDependencyContainer")
struct AppDependencyContainerTests {

    // MARK: - Lazy property identity

    @Test("Storage service returns same instance on repeated access")
    func storageServiceSameInstance() {
        let container = AppDependencyContainer()
        let s1 = container.taskStorageService as AnyObject
        let s2 = container.taskStorageService as AnyObject
        #expect(s1 === s2)
    }

    @Test("Repository returns same instance on repeated access")
    func repositorySameInstance() {
        let container = AppDependencyContainer()
        let r1 = container.taskRepository as AnyObject
        let r2 = container.taskRepository as AnyObject
        #expect(r1 === r2)
    }

    @Test("FetchTasksUseCase returns same instance on repeated access")
    func fetchUseCaseSameInstance() {
        let container = AppDependencyContainer()
        let u1 = container.fetchTasksUseCase as AnyObject
        let u2 = container.fetchTasksUseCase as AnyObject
        #expect(u1 === u2)
    }

    @Test("AddTaskUseCase returns same instance on repeated access")
    func addUseCaseSameInstance() {
        let container = AppDependencyContainer()
        let u1 = container.addTaskUseCase as AnyObject
        let u2 = container.addTaskUseCase as AnyObject
        #expect(u1 === u2)
    }

    @Test("UpdateTaskUseCase returns same instance on repeated access")
    func updateUseCaseSameInstance() {
        let container = AppDependencyContainer()
        let u1 = container.updateTaskUseCase as AnyObject
        let u2 = container.updateTaskUseCase as AnyObject
        #expect(u1 === u2)
    }

    @Test("DeleteTaskUseCase returns same instance on repeated access")
    func deleteUseCaseSameInstance() {
        let container = AppDependencyContainer()
        let u1 = container.deleteTaskUseCase as AnyObject
        let u2 = container.deleteTaskUseCase as AnyObject
        #expect(u1 === u2)
    }

    // MARK: - Different containers have independent instances

    @Test("Different containers produce separate storage services")
    func separateContainersHaveSeparateStorage() {
        let c1 = AppDependencyContainer()
        let c2 = AppDependencyContainer()
        let s1 = c1.taskStorageService as AnyObject
        let s2 = c2.taskStorageService as AnyObject
        #expect(s1 !== s2)
    }

    @Test("Different containers produce separate repositories")
    func separateContainersHaveSeparateRepositories() {
        let c1 = AppDependencyContainer()
        let c2 = AppDependencyContainer()
        let r1 = c1.taskRepository as AnyObject
        let r2 = c2.taskRepository as AnyObject
        #expect(r1 !== r2)
    }

    // MARK: - Factory methods

    @Test("makeTaskListViewModel creates view model with default state")
    @MainActor
    func makeTaskListViewModel() {
        let container = AppDependencyContainer()
        let vm = container.makeTaskListViewModel()
        #expect(vm.tasks.isEmpty)
        #expect(vm.filter == .all)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("makeTaskListViewModel creates independent instances")
    @MainActor
    func makeTaskListViewModelIndependent() {
        let container = AppDependencyContainer()
        let vm1 = container.makeTaskListViewModel()
        let vm2 = container.makeTaskListViewModel()
        #expect(vm1 !== vm2)
    }

    @Test("makeTaskDetailViewModel with nil task creates add mode")
    @MainActor
    func makeTaskDetailViewModelAddMode() {
        let container = AppDependencyContainer()
        let vm = container.makeTaskDetailViewModel(task: nil)
        #expect(vm.title == "")
        #expect(vm.isEditMode == false)
        #expect(vm.isSaved == false)
        #expect(vm.isSaving == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("makeTaskDetailViewModel with task creates edit mode")
    @MainActor
    func makeTaskDetailViewModelEditMode() {
        let container = AppDependencyContainer()
        let task = TaskItem(title: "Edit Me")
        let vm = container.makeTaskDetailViewModel(task: task)
        #expect(vm.title == "Edit Me")
        #expect(vm.isEditMode == true)
    }

    @Test("makeTaskDetailViewModel creates independent instances")
    @MainActor
    func makeTaskDetailViewModelIndependent() {
        let container = AppDependencyContainer()
        let vm1 = container.makeTaskDetailViewModel(task: nil)
        let vm2 = container.makeTaskDetailViewModel(task: nil)
        #expect(vm1 !== vm2)
    }

    @Test("makeAppCoordinator creates functional coordinator")
    @MainActor
    func makeAppCoordinator() {
        let container = AppDependencyContainer()
        let coordinator = container.makeAppCoordinator()
        let view = coordinator.start()
        _ = view
    }
}
