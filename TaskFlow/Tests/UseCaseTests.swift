import XCTest
@testable import TaskFlow

final class UseCaseTests: XCTestCase {
    
    var mockRepository: MockTaskRepository!
    var fetchUseCase: FetchTasksUseCaseImpl!
    var addUseCase: AddTaskUseCaseImpl!
    var updateUseCase: UpdateTaskUseCaseImpl!
    var deleteUseCase: DeleteTaskUseCaseImpl!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        fetchUseCase = FetchTasksUseCaseImpl(repository: mockRepository)
        addUseCase = AddTaskUseCaseImpl(repository: mockRepository)
        updateUseCase = UpdateTaskUseCaseImpl(repository: mockRepository)
        deleteUseCase = DeleteTaskUseCaseImpl(repository: mockRepository)
    }
    
    func testFetchTasksUseCase() async throws {
        let expectedTasks = [Task(title: "Task 1")]
        mockRepository.tasksToReturn = expectedTasks
        
        let tasks = try await fetchUseCase.execute()
        
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks[0].title, "Task 1")
    }
    
    func testAddTaskUseCase() async throws {
        let task = Task(title: "New Task")
        
        try await addUseCase.execute(task)
        
        XCTAssertTrue(mockRepository.addCalled)
        XCTAssertEqual(mockRepository.lastAddedTask?.id, task.id)
    }
    
    func testUpdateTaskUseCase() async throws {
        let task = Task(title: "Updated Task")
        
        try await updateUseCase.execute(task)
        
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertEqual(mockRepository.lastUpdatedTask?.id, task.id)
    }
    
    func testDeleteTaskUseCase() async throws {
        let task = Task(title: "Task to Delete")
        
        try await deleteUseCase.execute(task)
        
        XCTAssertTrue(mockRepository.deleteCalled)
        XCTAssertEqual(mockRepository.lastDeletedTask?.id, task.id)
    }
}

// MARK: - Mock Repository
class MockTaskRepository: TaskRepositoryProtocol {
    var tasksToReturn: [Task] = []
    var addCalled = false
    var updateCalled = false
    var deleteCalled = false
    var lastAddedTask: Task?
    var lastUpdatedTask: Task?
    var lastDeletedTask: Task?
    
    func fetchTasks() async throws -> [Task] {
        return tasksToReturn
    }
    
    func addTask(_ task: Task) async throws {
        addCalled = true
        lastAddedTask = task
    }
    
    func updateTask(_ task: Task) async throws {
        updateCalled = true
        lastUpdatedTask = task
    }
    
    func deleteTask(_ task: Task) async throws {
        deleteCalled = true
        lastDeletedTask = task
    }
}
