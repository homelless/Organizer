//
//  Task.swift
//  Organizer
//
//  Created by MacBookAir on 19.06.25.
//
import UIKit
import Foundation


struct Task {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var description: String?
    var date: Date? 
    
    enum Priority: String, CaseIterable {
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
