import SwiftUI
import SwiftData
import UserNotifications
import Foundation

@Observable
class SettingsViewModel {
    private var modelContext: ModelContext
    var showingAlert = false
    var alertMessage = ""
    private var lastRescheduleTime: Date = Date.distantPast
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Computed Properties
    
    var currentSettings: Settings {
        let settingsRequest = FetchDescriptor<Settings>()
        if let existingSettings = try? modelContext.fetch(settingsRequest).first {
            // Check if the daily goal is unreasonably high (indicating old ml data)
            if existingSettings.dailyGoal > 200 {
                // Reset to a reasonable oz value
                existingSettings.dailyGoal = 100
            }
            return existingSettings
        } else {
            let newSettings = Settings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }
    
    // MARK: - Methods
    
    func updateDailyGoal(_ newGoal: Int) {
        currentSettings.dailyGoal = newGoal
        saveContext()
    }
    
    func toggleNotifications(_ enabled: Bool) {
        currentSettings.notificationsEnabled = enabled
        saveContext()
        
        if enabled {
            requestNotificationPermission()
        } else {
            cancelAllNotifications()
        }
    }
    
    func updateNotificationStartTime(_ time: Date) {
        currentSettings.notificationStartTime = time
        saveContext()
        if currentSettings.notificationsEnabled {
            scheduleNotifications()
        }
    }
    
    func updateNotificationEndTime(_ time: Date) {
        currentSettings.notificationEndTime = time
        saveContext()
        if currentSettings.notificationsEnabled {
            scheduleNotifications()
        }
    }
    
    func updateNotificationInterval(_ interval: Int) {
        currentSettings.notificationInterval = interval
        saveContext()
        if currentSettings.notificationsEnabled {
            scheduleNotifications()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.scheduleNotifications()
                } else if let error = error {
                    self?.alertMessage = "Error: \(error.localizedDescription)"
                    self?.showingAlert = true
                }
            }
        }
    }
    
    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard currentSettings.notificationsEnabled else { return }
        
        let calendar = Calendar.current
        guard let startHour = calendar.dateComponents([.hour, .minute], from: currentSettings.notificationStartTime).hour,
              let endHour = calendar.dateComponents([.hour, .minute], from: currentSettings.notificationEndTime).hour else {
            return
        }
        
        // Get current hour to avoid scheduling notifications for past times today
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        
        for hour in stride(from: startHour, through: endHour, by: currentSettings.notificationInterval) {
            // Skip notifications that would have already fired today
            if hour <= currentHour && currentMinute > 0 {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Time to Hydrate! 💧"
            
            // Calculate current remaining water dynamically at scheduling time
            let remainingWater = getRemainingWaterForToday()
            if remainingWater > 0 {
                content.body = "You need \(remainingWater) more oz to reach your daily goal of \(currentSettings.dailyGoal) oz!"
            } else {
                content.body = "Great job! You've reached your daily goal of \(currentSettings.dailyGoal) oz! Keep it up! 🎉"
            }
            
            content.sound = .default
            content.categoryIdentifier = "WATER_REMINDER"
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "waterReminder-\(hour)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification for \(hour):00 - \(error)")
                } else {
                    print("Scheduled notification for \(hour):00 with \(remainingWater) oz remaining")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Public method to reschedule notifications when water intake changes
    
    func rescheduleNotificationsIfNeeded() {
        guard currentSettings.notificationsEnabled else { return }
        
        // Only reschedule if enough time has passed (minimum 5 minutes) or if it's the first reschedule
        let timeSinceLastReschedule = Date().timeIntervalSince(lastRescheduleTime)
        guard timeSinceLastReschedule > 300 || lastRescheduleTime == Date.distantPast else {
            return
        }
        
        lastRescheduleTime = Date()
        scheduleNotifications()
    }
    
    // MARK: - Immediate notification content update
    
    func updateNotificationContentImmediately() {
        // This method provides immediate updates for better user experience
        guard currentSettings.notificationsEnabled else { return }
        
        // Always update content regardless of timing constraints
        lastRescheduleTime = Date()
        scheduleNotifications()
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    private func getRemainingWaterForToday() -> Int {
        let waterRequest = FetchDescriptor<WaterEntry>()
        guard let waterEntries = try? modelContext.fetch(waterRequest) else { return currentSettings.dailyGoal }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayIntake = waterEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
        
        return max(currentSettings.dailyGoal - todayIntake, 0)
    }
} 