import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \WaterEntry.timestamp, order: .reverse) private var waterEntries: [WaterEntry]
    
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
                    Text("\(totalToday)ml")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                .padding(.vertical)
            }
            
            Section("Recommendation") {
                Text("Daily goal: 2000ml")
                if totalToday < 2000 {
                    Text("You need \(2000 - totalToday)ml more today")
                        .foregroundColor(.orange)
                } else {
                    Text("Great job! You've met your daily goal!")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Statistics")
    }
} 