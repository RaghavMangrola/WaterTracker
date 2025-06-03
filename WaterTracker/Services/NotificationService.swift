import UserNotifications
import Foundation

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func requestPermission(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func scheduleHydrationReminders(
        startHour: Int,
        endHour: Int,
        interval: Int,
        dailyGoal: Int,
        currentIntake: Int
    ) {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for hour in stride(from: startHour, through: endHour, by: interval) {
            let content = UNMutableNotificationContent()
            content.title = "Time to Hydrate! 💧"
            
            // Calculate remaining water dynamically
            let remainingWater = max(dailyGoal - currentIntake, 0)
            if remainingWater > 0 {
                content.body = "You need \(remainingWater) more oz to reach your daily goal of \(dailyGoal) oz!"
            } else {
                content.body = "Great job! You've reached your daily goal of \(dailyGoal) oz! Keep it up! 🎉"
            }
            
            content.sound = .default
            content.categoryIdentifier = "WATER_REMINDER"
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "waterReminder-\(hour)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
} 