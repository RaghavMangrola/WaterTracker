import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel?
    
    private var showingAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.showingAlert ?? false },
            set: { viewModel?.showingAlert = $0 }
        )
    }
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                Form {
                    Section("Daily Goal") {
                        Stepper("Goal: \(viewModel.currentSettings.dailyGoal) oz", 
                               value: .init(
                                get: { viewModel.currentSettings.dailyGoal },
                                set: { viewModel.updateDailyGoal($0) }
                               ),
                               in: 17...169,
                               step: 8)
                    }
                    
                    Section("Notifications") {
                        Toggle("Enable Reminders", isOn: .init(
                            get: { viewModel.currentSettings.notificationsEnabled },
                            set: { viewModel.toggleNotifications($0) }
                        ))
                        
                        if viewModel.currentSettings.notificationsEnabled {
                            DatePicker("Start Time",
                                     selection: .init(
                                        get: { viewModel.currentSettings.notificationStartTime },
                                        set: { viewModel.updateNotificationStartTime($0) }
                                     ),
                                     displayedComponents: .hourAndMinute)
                            
                            DatePicker("End Time",
                                     selection: .init(
                                        get: { viewModel.currentSettings.notificationEndTime },
                                        set: { viewModel.updateNotificationEndTime($0) }
                                     ),
                                     displayedComponents: .hourAndMinute)
                            
                            Picker("Reminder Interval", selection: .init(
                                get: { viewModel.currentSettings.notificationInterval },
                                set: { viewModel.updateNotificationInterval($0) }
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
                            viewModel.scheduleNotifications()
                        }
                        .disabled(!viewModel.currentSettings.notificationsEnabled)
                    }
                }
                .navigationTitle("Settings")
                .alert("Notifications", isPresented: showingAlertBinding) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.alertMessage)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(modelContext: modelContext)
            }
        }
    }
} 
