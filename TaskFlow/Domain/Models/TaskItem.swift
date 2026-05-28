import Foundation

/// The core domain model representing a single task in the application.
///
/// `TaskItem` holds all the data associated with a user's task, including its
/// title, completion state, priority, optional notes, due date, and category.
/// It conforms to `Codable` for persistence, `Identifiable` for SwiftUI list
/// rendering, and `Hashable` for use with `NavigationPath`.
///
/// A custom `Decodable` initializer provides backward compatibility so that
/// tasks saved before `priority`, `notes`, `dueDate`, and `category` were
/// introduced can still be decoded without data loss.
struct TaskItem: Identifiable, Codable, Equatable, Hashable {
    /// Unique identifier for the task, generated automatically on creation.
    let id: UUID

    /// The user-facing title describing what needs to be done.
    var title: String

    /// Whether the task has been marked as completed.
    var isCompleted: Bool

    /// The date and time the task was originally created.
    let createdAt: Date

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

    /// Backward-compatible decoder that gracefully handles tasks stored before
    /// `priority`, `notes`, `dueDate`, and `category` fields were added.
    ///
    /// Missing fields fall back to their default values rather than throwing.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        priority = try container.decodeIfPresent(TaskPriority.self, forKey: .priority) ?? .medium
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        category = try container.decodeIfPresent(TaskCategory.self, forKey: .category) ?? .personal
    }
}
