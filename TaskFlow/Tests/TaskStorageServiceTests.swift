import XCTest
@testable import TaskFlow

final class TaskStorageServiceTests: XCTestCase {
    
    var storageService: TaskStorageService!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "TestUserDefaults")
        storageService = TaskStorageService(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TestUserDefaults")
        super.tearDown()
    }
    
    func testFetchTasksWhenEmpty() throws {
        let tasks = try storageService.fetchTasks()
        
        XCTAssertTrue(tasks.isEmpty)
    }
    
    func testSaveAndFetchTasks() throws {
        let task1 = Task(title: "Task 1")
        let task2 = Task(title: "Task 2")
        let tasks = [task1, task2]
        
        try storageService.saveTasks(tasks)
        let fetchedTasks = try storageService.fetchTasks()
        
        XCTAssertEqual(fetchedTasks.count, 2)
        XCTAssertEqual(fetchedTasks[0].id, task1.id)
        XCTAssertEqual(fetchedTasks[1].id, task2.id)
    }
    
    func testSaveTasksOverwritesExisting() throws {
        let task1 = Task(title: "Task 1")
        let task2 = Task(title: "Task 2")
        
        try storageService.saveTasks([task1])
        try storageService.saveTasks([task2])
        
        let fetchedTasks = try storageService.fetchTasks()
        
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks[0].id, task2.id)
    }
}
