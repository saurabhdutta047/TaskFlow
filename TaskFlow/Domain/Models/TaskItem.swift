import Foundation
import SwiftData

/// The core domain model representing a single task in the application.
///
/// `TaskItem` holds all the data associated with a user's task, including its
/// title, completion state, priority, optional notes, due date, and category.
/// It conforms to `Identifiable` for SwiftUI list rendering and `Hashable` for
/// use with `NavigationPath`.
///
/// This model uses SwiftData for persistence, providing automatic database
/// management and query capabilities.
@Model
final class TaskItem: Identifiable, Hashable {
    /// Unique identifier for the task, generated automatically on creation.
    var id: UUID

    /// The user-facing title describing what needs to be done.
    var title: String

    /// Whether the task has been marked as completed.
    var isCompleted: Bool

    /// The date and time the task was originally created.
    var createdAt: Date

    /// The urgency level of the task (low, medium, or high).
    var priority: TaskPriority

    /// Optional free-form notes or details about the task.
    var notes: String

    /// An optional deadline for the task.
    var dueDate: Date?

    /// The organizational category the task belongs to (e.g. work, personal).
    var category: TaskCategory

    /// Creates a new task with sensible defaults.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID.
    ///   - title: The task title.
    ///   - isCompleted: Completion state. Defaults to `false`.
    ///   - createdAt: Creation timestamp. Defaults to the current date.
    ///   - priority: Urgency level. Defaults to `.medium`.
    ///   - notes: Additional details. Defaults to an empty string.
    ///   - dueDate: Optional deadline. Defaults to `nil`.
    ///   - category: Task category. Defaults to `.personal`.
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date(), priority: TaskPriority = .medium, notes: String = "", dueDate: Date? = nil, category: TaskCategory = .personal) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.priority = priority
        self.notes = notes
        self.dueDate = dueDate
        self.category = category
    }
}
