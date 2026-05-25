import Foundation

struct TaskItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    var priority: TaskPriority
    var notes: String
    var dueDate: Date?
    var category: TaskCategory

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
