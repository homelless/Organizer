import UIKit
import Foundation

struct Task: Codable {
    
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var description: String? = nil
    
    enum Priority: String, Codable, CaseIterable, Equatable {
        case low = "Когда-то"
        case medium = "Надо бы"
        case high = "Срочно"
       
        var color: UIColor {
            switch self {
            case .low: return .systemGreen
            case .medium: return .systemOrange
            case .high: return .systemRed
            }
        }
    }
}

// Расширение для возможности сравнения только по id 
extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}
