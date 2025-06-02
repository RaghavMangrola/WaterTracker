import SwiftUI
import SwiftData
import Foundation

@Observable
class StatsViewModel {
    private var modelContext: ModelContext
    var waterEntries: [WaterEntry] = []
    var selectedPeriod: StatsPeriod = .week
    
    enum StatsPeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadWaterEntries()
    }
    
    // MARK: - Computed Properties
    
    var currentSettings: Settings {
        let settingsRequest = FetchDescriptor<Settings>()
        if let existingSettings = try? modelContext.fetch(settingsRequest).first {
            if existingSettings.dailyGoal > 200 {
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
    
    var todayProgressPercentage: Double {
        min(Double(todayIntake) / Double(currentSettings.dailyGoal), 1.0)
    }
    
    var chartData: [DailyIntake] {
        let calendar = Calendar.current
        let numberOfDays = selectedPeriod == .week ? 7 : 30
        
        var data: [DailyIntake] = []
        
        for i in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let startOfDay = calendar.startOfDay(for: date)
            
            let dailyTotal = waterEntries
                .filter { calendar.isDate($0.timestamp, inSameDayAs: startOfDay) }
                .reduce(0) { $0 + $1.amount }
            
            data.append(DailyIntake(date: startOfDay, amount: dailyTotal))
        }
        
        return data.reversed()
    }
    
    var averageIntake: Double {
        let data = chartData
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.amount }
        return Double(total) / Double(data.count)
    }
    
    var bestDay: Int {
        chartData.map { $0.amount }.max() ?? 0
    }
    
    var goalAchievementRate: Double {
        let data = chartData
        guard !data.isEmpty else { return 0 }
        let goalDays = data.filter { $0.amount >= currentSettings.dailyGoal }.count
        return Double(goalDays) / Double(data.count) * 100
    }
    
    var periodText: String {
        switch selectedPeriod {
        case .week:
            return "Past 7 Days"
        case .month:
            return "Past 30 Days"
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
    
    func togglePeriod() {
        selectedPeriod = selectedPeriod == .week ? .month : .week
    }
}

// MARK: - Supporting Types

struct DailyIntake: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Int
} 