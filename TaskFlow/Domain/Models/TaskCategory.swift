import Foundation

/// Organizational categories that a task can belong to.
///
/// Categories help users group and visually distinguish their tasks.
/// Each case provides a user-facing label via its raw value.
enum TaskCategory: String, Codable, CaseIterable, Hashable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case education = "Education"
    case other = "Other"
}
