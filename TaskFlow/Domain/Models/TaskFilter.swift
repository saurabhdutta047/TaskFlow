import Foundation

/// Filter options for displaying subsets of the task list.
///
/// Used by `TaskListViewModel` to determine which tasks are visible
/// in the current view. The raw value is the user-facing label shown
/// in the segmented filter tabs.
enum TaskFilter: String, CaseIterable {
    /// Show all tasks regardless of completion state.
    case all = "All"

    /// Show only tasks that have not been completed.
    case active = "Active"

    /// Show only tasks that have been marked as completed.
    case completed = "Completed"
}
