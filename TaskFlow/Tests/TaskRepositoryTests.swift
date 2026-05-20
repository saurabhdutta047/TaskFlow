import XCTest
@testable import TaskFlow

final class TaskRepositoryTests: XCTestCase {
    
    var repository: TaskRepository!
    var mockStorageService: MockTaskStorageService!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockTaskStorageService()
        repository = TaskRepository(storageService: mockStorageService)
    }
    
    func testFetchTasks() async throws {
        let expectedTasks = [Task(title: "Task 1"), Task(title: "Task 2")]
        mockStorageService.tasksToReturn = expectedTasks
        
        let tasks = try await repository.fetchTasks()
        
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks[0].title, "Task 1")
    }
    
    func testAddTask() async throws {
        let task = Task(title: "New Task")
        
        try await repository.addTask(task)
        
        XCTAssertEqual(mockStorageService.savedTasks.count, 1)
        XCTAssertEqual(mockStorageService.savedTasks[0].id, task.id)
    }
    
    func testUpdateTask() async throws {
        let task = Task(title: "Original Task")
        mockStorageService.tasksToReturn = [task]
        
        var updatedTask = task
        updatedTask.title = "Updated Task"
        
        try await repository.updateTask(updatedTask)
        
        XCTAssertEqual(mockStorageService.savedTasks.count, 1)
        XCTAssertEqual(mockStorageService.savedTasks[0].title, "Updated Task")
    }
    
    func testDeleteTask() async throws {
        let task1 = Task(title: "Task 1")
        let task2 = Task(title: "Task 2")
        mockStorageService.tasksToReturn = [task1, task2]
        
        try await repository.deleteTask(task1)
        
        XCTAssertEqual(mockStorageService.savedTasks.count, 1)
        XCTAssertEqual(mockStorageService.savedTasks[0].id, task2.id)
    }
}

// MARK: - Mock Storage Service
class MockTaskStorageService: TaskStorageServiceProtocol {
    var tasksToReturn: [Task] = []
    var savedTasks: [Task] = []
    
    func fetchTasks() throws -> [Task] {
        return tasksToReturn
    }
    
    func saveTasks(_ tasks: [Task]) throws {
        savedTasks = tasks
    }
}
