import Foundation
import SwiftData

@Model
class Settings {
    var dailyGoal: Int
    var notificationsEnabled: Bool
    var notificationStartTime: Date
    var notificationEndTime: Date
    var notificationInterval: Int // in hours
    
    init(dailyGoal: Int = 2000, 
         notificationsEnabled: Bool = false,
         notificationStartTime: Date = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date(),
         notificationEndTime: Date = Calendar.current.date(from: DateComponents(hour: 22)) ?? Date(),
         notificationInterval: Int = 2) {
        self.dailyGoal = dailyGoal
        self.notificationsEnabled = notificationsEnabled
        self.notificationStartTime = notificationStartTime
        self.notificationEndTime = notificationEndTime
        self.notificationInterval = notificationInterval
    }
} 