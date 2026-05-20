import XCTest
@testable import TaskFlow

final class TaskModelTests: XCTestCase {
    
    func testTaskInitialization() {
        let task = Task(title: "Test Task")
        
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.id)
    }
    
    func testTaskWithCustomValues() {
        let id = UUID()
        let date = Date()
        let task = Task(id: id, title: "Custom Task", isCompleted: true, createdAt: date)
        
        XCTAssertEqual(task.id, id)
        XCTAssertEqual(task.title, "Custom Task")
        XCTAssertTrue(task.isCompleted)
        XCTAssertEqual(task.createdAt, date)
    }
    
    func testTaskEquatable() {
        let id = UUID()
        let task1 = Task(id: id, title: "Task", isCompleted: false, createdAt: Date())
        let task2 = Task(id: id, title: "Task", isCompleted: false, createdAt: Date())
        
        XCTAssertEqual(task1, task2)
    }
    
    func testTaskCodable() {
        let task = Task(title: "Test Task")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(task)
            
            let decoder = JSONDecoder()
            let decodedTask = try decoder.decode(Task.self, from: data)
            
            XCTAssertEqual(task.id, decodedTask.id)
            XCTAssertEqual(task.title, decodedTask.title)
            XCTAssertEqual(task.isCompleted, decodedTask.isCompleted)
        } catch {
            XCTFail("Encoding/Decoding failed: \(error)")
        }
    }
}
