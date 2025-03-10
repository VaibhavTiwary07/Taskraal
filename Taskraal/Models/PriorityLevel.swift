//
//  PriorityLevel.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 10/03/25.
//

import Foundation
import UIKit
import CoreData

enum PriorityLevel:Int16,CaseIterable{
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String{
        switch self{
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    
    var color: UIColor {
        switch self {
        case .low:
            return .systemBlue
        case .medium:
            return .systemOrange
        case .high:
            return .systemRed
        }
    }
}
