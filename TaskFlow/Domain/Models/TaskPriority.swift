import Foundation

/// Priority levels that indicate a task's urgency.
///
/// Displayed as selectable pills in the task creation/edit form and as
/// colored indicators in the task details screen.
enum TaskPriority: String, Codable, CaseIterable, Hashable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}
