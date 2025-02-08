import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Get the first settings object or create one if it doesn't exist
    private var currentSettings: Settings {
        if let firstSettings = settings.first {
            return firstSettings
        } else {
            let newSettings = Settings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }
    
    var body: some View {
        Form {
            Section("Daily Goal") {
                Stepper("Goal: \(currentSettings.dailyGoal)ml", 
                       value: .init(
                        get: { currentSettings.dailyGoal },
                        set: { currentSettings.dailyGoal = $0 }
                       ),
                       in: 500...5000,
                       step: 250)
            }
            
            Section("Notifications") {
                Toggle("Enable Reminders", isOn: .init(
                    get: { currentSettings.notificationsEnabled },
                    set: { newValue in
                        currentSettings.notificationsEnabled = newValue
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            cancelAllNotifications()
                        }
                    }
                ))
                
                if currentSettings.notificationsEnabled {
                    DatePicker("Start Time",
                             selection: .init(
                                get: { currentSettings.notificationStartTime },
                                set: { currentSettings.notificationStartTime = $0 }
                             ),
                             displayedComponents: .hourAndMinute)
                    
                    DatePicker("End Time",
                             selection: .init(
                                get: { currentSettings.notificationEndTime },
                                set: { currentSettings.notificationEndTime = $0 }
                             ),
                             displayedComponents: .hourAndMinute)
                    
                    Picker("Reminder Interval", selection: .init(
                        get: { currentSettings.notificationInterval },
                        set: { currentSettings.notificationInterval = $0 }
                    )) {
                        Text("1 hour").tag(1)
                        Text("2 hours").tag(2)
                        Text("3 hours").tag(3)
                        Text("4 hours").tag(4)
                    }
                }
            }
            
            Section {
                Button("Schedule Notifications") {
                    scheduleNotifications()
                }
                .disabled(!currentSettings.notificationsEnabled)
            }
        }
        .navigationTitle("Settings")
        .alert("Notifications", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: currentSettings.notificationsEnabled) {
            if currentSettings.notificationsEnabled {
                scheduleNotifications()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    scheduleNotifications()
                } else if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard currentSettings.notificationsEnabled else { return }
        
        let calendar = Calendar.current
        guard let startHour = calendar.dateComponents([.hour, .minute], from: currentSettings.notificationStartTime).hour,
              let endHour = calendar.dateComponents([.hour, .minute], from: currentSettings.notificationEndTime).hour else {
            return
        }
        
        for hour in stride(from: startHour, through: endHour, by: currentSettings.notificationInterval) {
            let content = UNMutableNotificationContent()
            content.title = "Time to Hydrate!"
            content.body = "Don't forget to drink some water 💧"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "waterReminder-\(hour)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 