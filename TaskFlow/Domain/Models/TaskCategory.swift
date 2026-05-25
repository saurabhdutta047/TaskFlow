import Foundation

enum TaskCategory: String, Codable, CaseIterable, Hashable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case education = "Education"
    case other = "Other"
}
