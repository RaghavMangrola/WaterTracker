import SwiftUI
import SwiftData
import Foundation

@Observable
class ContentViewModel {
    private var modelContext: ModelContext
    var waterEntries: [WaterEntry] = []
    var showingAddSheet = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadWaterEntries()
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
    
    var todayIntake: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return waterEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var progressPercentage: Double {
        min(Double(todayIntake) / Double(currentSettings.dailyGoal), 1.0)
    }
    
    var remainingOz: Int {
        max(currentSettings.dailyGoal - todayIntake, 0)
    }
    
    var isGoalReached: Bool {
        remainingOz == 0
    }
    
    var progressText: String {
        "\(todayIntake) / \(currentSettings.dailyGoal) oz"
    }
    
    var progressPercentageText: String {
        "\(Int(progressPercentage * 100))%"
    }
    
    var remainingText: String {
        if remainingOz > 0 {
            return "\(remainingOz) oz left"
        } else {
            return "Goal reached! 🎉"
        }
    }
    
    // MARK: - Methods
    
    func loadWaterEntries() {
        let request = FetchDescriptor<WaterEntry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            waterEntries = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch water entries: \(error)")
            waterEntries = []
        }
    }
    
    func addWater(amount: Int) {
        let entry = WaterEntry(amount: amount)
        modelContext.insert(entry)
        
        // Save the context
        do {
            try modelContext.save()
            loadWaterEntries() // Refresh the list
        } catch {
            print("Failed to save water entry: \(error)")
        }
    }
    
    func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(waterEntries[index])
        }
        
        do {
            try modelContext.save()
            loadWaterEntries() // Refresh the list
        } catch {
            print("Failed to delete entries: \(error)")
        }
    }
    
    func toggleAddSheet() {
        showingAddSheet.toggle()
    }
} 