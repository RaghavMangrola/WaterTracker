import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var waterEntries: [WaterEntry] = []
    
    private var currentSettings: Settings {
        let settingsRequest = FetchDescriptor<Settings>()
        if let existingSettings = try? modelContext.fetch(settingsRequest).first {
            // Check if the daily goal is unreasonably high (indicating old ml data)
            if existingSettings.dailyGoal > 200 {
                // Reset to a reasonable oz value
                existingSettings.dailyGoal = 100
            }
            return existingSettings
        } else {
            return Settings()
        }
    }
    
    var totalToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return waterEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        List {
            Section("Today's Progress") {
                VStack(alignment: .leading) {
                    Text("Total water consumed:")
                        .font(.headline)
                    Text("\(totalToday) oz")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                .padding(.vertical)
            }
            
            Section("Recommendation") {
                Text("Daily goal: \(currentSettings.dailyGoal) oz")
                if totalToday < currentSettings.dailyGoal {
                    Text("You need \(currentSettings.dailyGoal - totalToday) oz more today")
                        .foregroundColor(.orange)
                } else {
                    Text("Great job! You've met your daily goal!")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Statistics")
        .onAppear {
            loadWaterEntries()
        }
    }
    
    private func loadWaterEntries() {
        let request = FetchDescriptor<WaterEntry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            waterEntries = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch water entries: \(error)")
            waterEntries = []
        }
    }
} 