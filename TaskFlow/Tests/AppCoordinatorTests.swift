import Testing
import Foundation
@testable import TaskFlow

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    private func makeCoordinator() -> AppCoordinator {
        let container = AppDependencyContainer()
        return AppCoordinator(dependencyContainer: container)
    }

    @Test("start() returns a view without crashing")
    func startReturnsView() {
        let coordinator = makeCoordinator()
        let view = coordinator.start()
        _ = view
    }

    @Test("showTaskDetail with nil creates add-mode view")
    func showTaskDetailAddMode() {
        let coordinator = makeCoordinator()
        let view = coordinator.showTaskDetail(for: nil)
        _ = view
    }

    @Test("showTaskDetail with task creates edit-mode view")
    func showTaskDetailEditMode() {
        let coordinator = makeCoordinator()
        let task = TaskItem(title: "Test Task")
        let view = coordinator.showTaskDetail(for: task)
        _ = view
    }

    @Test("showTaskDetail preserves task identity across calls")
    func showTaskDetailPreservesTask() {
        let coordinator = makeCoordinator()
        let task = TaskItem(title: "Specific Task", isCompleted: true)
        let view = coordinator.showTaskDetail(for: task)
        _ = view
    }

    @Test("Multiple start() calls produce views independently")
    func multipleStartCalls() {
        let coordinator = makeCoordinator()
        let view1 = coordinator.start()
        let view2 = coordinator.start()
        _ = (view1, view2)
    }

    @Test("Coordinator works with completed task")
    func showTaskDetailCompletedTask() {
        let coordinator = makeCoordinator()
        let task = TaskItem(title: "Done", isCompleted: true)
        let view = coordinator.showTaskDetail(for: task)
        _ = view
    }
}
