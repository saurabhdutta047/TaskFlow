import XCTest
@testable import TaskFlow

@MainActor
final class TaskListViewModelTests: XCTestCase {
    
    var viewModel: TaskListViewModel!
    var mockFetchUseCase: MockFetchTasksUseCase!
    var mockAddUseCase: MockAddTaskUseCase!
    var mockUpdateUseCase: MockUpdateTaskUseCase!
    var mockDeleteUseCase: MockDeleteTaskUseCase!
    
    override func setUp() {
        super.setUp()
        mockFetchUseCase = MockFetchTasksUseCase()
        mockAddUseCase = MockAddTaskUseCase()
        mockUpdateUseCase = MockUpdateTaskUseCase()
        mockDeleteUseCase = MockDeleteTaskUseCase()
        
        viewModel = TaskListViewModel(
            fetchTasksUseCase: mockFetchUseCase,
            addTaskUseCase: mockAddUseCase,
            updateTaskUseCase: mockUpdateUseCase,
            deleteTaskUseCase: mockDeleteUseCase
        )
    }
    
    func testLoadTasksSuccess() async {
        let expectedTasks = [
            Task(title: "Task 1", isCompleted: false),
            Task(title: "Task 2", isCompleted: true)
        ]
        mockFetchUseCase.tasksToReturn = expectedTasks
        
        await viewModel.loadTasks()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.tasks.count, 2)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadTasksFailure() async {
        mockFetchUseCase.shouldThrowError = true
        
        await viewModel.loadTasks()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.tasks.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFilteredTasksAll() async {
        let tasks = [
            Task(title: "Task 1", isCompleted: false),
            Task(title: "Task 2", isCompleted: true)
        ]
        mockFetchUseCase.tasksToReturn = tasks
        await viewModel.loadTasks()
        
        viewModel.filter = .all
        
        XCTAssertEqual(viewModel.filteredTasks.count, 2)
    }
    
    func testFilteredTasksActive() async {
        let tasks = [
            Task(title: "Task 1", isCompleted: false),
            Task(title: "Task 2", isCompleted: true)
        ]
        mockFetchUseCase.tasksToReturn = tasks
        await viewModel.loadTasks()
        
        viewModel.filter = .active
        
        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertFalse(viewModel.filteredTasks[0].isCompleted)
    }
    
    func testFilteredTasksCompleted() async {
        let tasks = [
            Task(title: "Task 1", isCompleted: false),
            Task(title: "Task 2", isCompleted: true)
        ]
        mockFetchUseCase.tasksToReturn = tasks
        await viewModel.loadTasks()
        
        viewModel.filter = .completed
        
        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertTrue(viewModel.filteredTasks[0].isCompleted)
    }
    
    func testToggleTaskCompletion() async {
        let task = Task(title: "Task 1", isCompleted: false)
        mockFetchUseCase.tasksToReturn = [task]
        await viewModel.loadTasks()
        
        await viewModel.toggleTaskCompletion(task)
        
        XCTAssertTrue(mockUpdateUseCase.called)
    }
    
    func testDeleteTask() async {
        let task = Task(title: "Task 1")
        mockFetchUseCase.tasksToReturn = [task]
        await viewModel.loadTasks()
        
        await viewModel.deleteTask(task)
        
        XCTAssertTrue(mockDeleteUseCase.called)
    }
}

// MARK: - Mock Use Cases
class MockFetchTasksUseCase: FetchTasksUseCase {
    var tasksToReturn: [Task] = []
    var shouldThrowError = false
    
    func execute() async throws -> [Task] {
        if shouldThrowError {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return tasksToReturn
    }
}

class MockAddTaskUseCase: AddTaskUseCase {
    func execute(_ task: Task) async throws {}
}

class MockUpdateTaskUseCase: UpdateTaskUseCase {
    var called = false
    
    func execute(_ task: Task) async throws {
        called = true
    }
}

class MockDeleteTaskUseCase: DeleteTaskUseCase {
    var called = false
    
    func execute(_ task: Task) async throws {
        called = true
    }
}
