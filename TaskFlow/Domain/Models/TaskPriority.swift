import Foundation

enum TaskPriority: String, Codable, CaseIterable, Hashable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}
