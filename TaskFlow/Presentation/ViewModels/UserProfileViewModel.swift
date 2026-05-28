import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var totalTasks = 0
    @Published var completedTasks = 0

    private let fetchTasksUseCase: FetchTasksUseCase

    var efficiencyScore: Int {
        totalTasks > 0 ? Int(Double(completedTasks) / Double(totalTasks) * 100) : 0
    }

    init(fetchTasksUseCase: FetchTasksUseCase) {
        self.fetchTasksUseCase = fetchTasksUseCase
    }

    func loadStats() async {
        do {
            let tasks = try await fetchTasksUseCase.execute()
            totalTasks = tasks.count
            completedTasks = tasks.filter { $0.isCompleted }.count
        } catch {
            // Silently handle stats load failure
        }
    }
}
