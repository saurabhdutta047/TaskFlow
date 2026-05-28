import Foundation

/// View model for the user profile / settings screen.
///
/// Fetches task statistics from the repository to display productivity
/// metrics such as total completed tasks and efficiency score.
@MainActor
final class UserProfileViewModel: ObservableObject {
    /// The total number of tasks in storage.
    @Published var totalTasks = 0

    /// The number of tasks marked as completed.
    @Published var completedTasks = 0

    private let fetchTasksUseCase: FetchTasksUseCase

    /// Completion percentage (0–100). Returns 0 when there are no tasks.
    var efficiencyScore: Int {
        totalTasks > 0 ? Int(Double(completedTasks) / Double(totalTasks) * 100) : 0
    }

    /// - Parameter fetchTasksUseCase: Use case for retrieving the task list.
    init(fetchTasksUseCase: FetchTasksUseCase) {
        self.fetchTasksUseCase = fetchTasksUseCase
    }

    /// Loads aggregate task statistics from the repository.
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
