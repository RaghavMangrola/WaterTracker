//
//  ContentView.swift
//  WaterTracker
//
//  Created by Raghav Mangrola on 2/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var waterEntries: [WaterEntry] = []
    @State private var showingAddSheet = false
    
    // Computed property to get settings
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
            let newSettings = Settings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }
    
    private var todayIntake: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return waterEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var progressPercentage: Double {
        min(Double(todayIntake) / Double(currentSettings.dailyGoal), 1.0)
    }
    
    private var remainingOz: Int {
        max(currentSettings.dailyGoal - todayIntake, 0)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Daily Progress Section
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today's Progress")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(todayIntake) / \(currentSettings.dailyGoal) oz")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            if remainingOz > 0 {
                                Text("\(remainingOz) oz left")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Goal reached! 🎉")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage, height: 12)
                                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        }
                    }
                    .frame(height: 12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                List {
                    ForEach(waterEntries) { entry in
                        NavigationLink {
                            WaterEntryDetailView(entry: entry)
                        } label: {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("\(entry.amount) oz")
                                        .font(.headline)
                                    Text(entry.timestamp, format: .dateTime)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        QuickAddButton(
                            amount: 8, // 8 oz
                            displayAmount: "8 oz",
                            icon: "waterbottle",
                            action: addWater
                        )
                        QuickAddButton(
                            amount: 40, // 40 oz
                            displayAmount: "40 oz", 
                            icon: "waterbottle.fill",
                            action: addWater
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 2)
            }
            .navigationTitle("Water Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: StatsView()) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWaterEntryView()
            }
            .onAppear {
                loadWaterEntries()
            }
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
    
    private func addWater(amount: Int) {
        withAnimation {
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
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(waterEntries[index])
            }
            
            // Save the context
            do {
                try modelContext.save()
                loadWaterEntries() // Refresh the list
            } catch {
                print("Failed to save after deletion: \(error)")
            }
        }
    }
}

struct QuickAddButton: View {
    let amount: Int
    let displayAmount: String
    let icon: String
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(amount) }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                Text(displayAmount)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.blue)
            .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
