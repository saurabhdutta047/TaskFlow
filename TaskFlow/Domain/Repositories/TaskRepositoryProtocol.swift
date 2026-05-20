import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks() async throws -> [Task]
    func addTask(_ task: Task) async throws
    func updateTask(_ task: Task) async throws
    func deleteTask(_ task: Task) async throws
}
