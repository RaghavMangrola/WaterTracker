import Foundation
import SwiftData

@Model
class WaterEntry {
    var amount: Int
    var timestamp: Date
    
    init(amount: Int, timestamp: Date = Date()) {
        self.amount = amount
        self.timestamp = timestamp
    }
} 