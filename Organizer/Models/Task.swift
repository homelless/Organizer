import UIKit
import Foundation

struct Task: Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var description: String? = nil
    
    enum Priority: String,Codable,CaseIterable {
        case low = "Низкий"
        case medium = "Средний"
        case high = "Высокий"
        
        var color: UIColor {
            switch self {
            case .low: return .systemGreen
            case .medium: return .systemOrange
            case .high: return .systemRed
            }
        }
    }
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}
